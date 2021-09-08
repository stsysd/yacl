{{
  const LOC = Symbol("LOCATION");

  function parseDocument(lines) {
  	const ls = lines.slice(0, -1);
    const indent = lines.slice(-1)[0];
    if (ls.some((line) => !line.startsWith(indent))) {
      throw new Error('invalid indentation');
    }
    return ls.map((line) => line.slice(indent.length)).join("\n");
  }

  function merge(x, y) {
    if (typeof x !== 'object') {
      throw new Error('key duplication');
    }
    if (typeof y !== 'object') {
      const e = new Error('unexpected primitive value');
      e[LOC] = y[LOC];
      throw e;
    }
    if (Array.isArray(x) && Array.isArray(y)) {
      return [...x, ...y];
    }
    if (Array.isArray(x)) {
      throw new Error('unexpected non-list value');
    }
    if (Array.isArray(y)) {
      throw new Error('unexpected list value');
    }

    try {
      for (const [k, v] of Object.entries(y)) {
        if (k in x) {
          x[k] = merge(x[k], v);
        } else {
          x[k] = v;
        }
      }
      return x;
    } catch (e) {
      e[LOC] = e[LOC] ?? y[LOC];
      throw e;
    }
  }
}}


TOP = @Body _

EOS = &{
  const { source, start, end } = range();
  return source.length === start && start === end + 1;
}

EOL = BLANK (COMMENT / ("\n" "\r"?) / EOS)

COMMENT = "#" (!"\n" .)* "\n" "\r"?

BLANK = " "*

_ "WHITESPACE" = (" " / "\n" / "\r" / COMMENT)*


Ident = !Lit @$([a-zA-Z$_] [0-9a-zA-Z$_]*)

Lit = Document / String / Number / Boolean / Null

String = "\"" content:(!("\"" / "\\" / "\n") @(. / EscapedChar))* "\"" {
    return content.join("")
}
EscapedChar = "\\n" { return "\n" }
            / "\\r" { return "\r" }
            / "\\t" { return "\t" }
            / "\\" @.

Document = "\"\"\"" EOL content:(!"\"\"\"" @.)* "\"\"\"" {
  try {
    return parseDocument(content.join("").split("\n"));
  } catch (e) {
    error(e.message);
  }
}

Number = Binary / Octal / Hex / Exp / Float / Digit
Sign = ("+" / "-")?

Digit = Sign [0-9]+ {
  return Number(text());
}

Binary = Sign ("0b" / "0B") [0-1]+ {
  return Number(text())
}

Octal = Sign ("0o" / "0O") [0-7]+ {
  return Number(text())
}

Hex = Sign ("0x" / "0X") [0-9a-fA-F]+ {
  return Number(text())
}

Float = Sign [0-9]+ "." [0-9]+ {
  return Number(text())
}

Exp = (Digit / Float) ("e" / "E") Sign? [0-9]+ {
  return Number(text())
}

Boolean = Truthy / Falsy

Truthy = "true" / "yes" / "on" { return true; }
Falsy = "false" / "no" / "off"  { return false; }

Null = "null" { return null; }


Sep = _ "," / EOL

List = "[" _ "]" { return []; }
     / "[" _ head:Expr tail:(Sep _ @Expr)* Sep? _ "]" {
       return [head, ...tail];
     }


Table = "{" _ "}" { return {}; }
      / "{" _ head:Member tail:(Sep _ @Member)* Sep? _ "}" {
        return Object.fromEntries([head, ...tail, [LOC, location()]]);
      }
Member = id:(Ident / String) _ ":"  _ val:Expr {
  return [id, val];
}

Collection = List / Table

Expr = Lit / Collection


Body = head:Statement tail:(_ @Statement)* {
  try {
    return tail.reduce(merge, head);
  } catch (e) {
    error(e.message, e[LOC]);
  }
}

Statement = Attribute / Block / (@Expr EOL)

Key = id:(Ident / String) bracket:(_ "[]")? {
  return { id, bracket: bracket != null}
}

Keys = head:Key tail:(_ @Key)* { return [head, ...tail]; }

Attribute = key:Key _ "=" _ value:Expr EOL {
  const { id, bracket } = key;
  return {
    [id]: bracket ? [value] : value,
    [LOC]: location(),
  };
}

Block = keys:Keys? _ "{" body:(EOL _ @Body)? _ "}" EOL {
  if (keys == null) return body;
  let ret = body ?? {};
  for (const { id, bracket } of keys.reverse()) {
    ret = { [id]: bracket ? [ret] : ret };
  }
  ret[LOC] = location();
  return ret;
}


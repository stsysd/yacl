# Yet Another Configuration Language

"yacl" is a JSON compatible, hcl-like syntax, and human readable configuration language.

A example is like this.

```hcl
digit = 123
binary = 0b111
octal = 0o123
Hex = 0x123
float = 3.14
exp = 10e-12

str = "hello"
doc = """
  foo
  bar
    baz
  """

t = true
f = false
n = null

list = [1, 2, 3, true]

table = { foo: "bar", baz: "qux" }

block {
  value = 1
  nested {
    value = 2
  }
}

block merge {
  foo = true
}

block merge {
  bar = false
}


block append [] {
  name = "taro"
  age = 30
}

block append [] {
  name = "jiro"
  age = 25
}

```

This is equivalent to this JSON.


```json
{
  "digit": 123,
  "binary": 7,
  "octal": 83,
  "Hex": 291,
  "float": 3.14,
  "exp": 1e-11,
  "str": "hello",
  "doc": "foo\nbar\n  baz",
  "t": "true",
  "f": "false",
  "n": null,
  "list": [
    1,
    2,
    3,
    "true"
  ],
  "table": {
    "foo": "bar",
    "baz": "qux"
  },
  "block": {
    "value": 1,
    "nested": {
      "value": 2
    },
    "merge": {
      "foo": "true",
      "bar": "false"
    },
    "append": [
      {
        "name": "taro",
        "age": 30
      },
      {
        "name": "jiro",
        "age": 25
      }
    ]
  }
}

```


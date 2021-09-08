const { parse, SyntaxError } = require("./generated/parser");

const YACL = {
  parse(text) {
    try {
      return parse(text, { grammarSource: "<INPUT>" });
    } catch (e) {
      if (e instanceof SyntaxError) {
        throw new Error(e.format([{ source: "<INPUT>", text }]));
      }
      throw e;
    }
  },
  async parseFile(fname) {
    const { readFile } = require("fs").promises;
    const text = (await readFile(fname)).toString();
    try {
      return parse(text, { grammarSource: fname });
    } catch (e) {
      if (e instanceof SyntaxError) {
        throw new Error(e.format([{ source: fname, text }]));
      }
      throw e;
    }
  },
};

module.exports = YACL;

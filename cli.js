#! /usr/bin/env node
const parseArgs = require("minimist");
const { parseFile } = require("./lib");

const args = parseArgs(process.argv.slice(2), {
  string: ["output"],
  boolean: ["format"],
  alias: { output: "o", format: "f" },
  default: { output: "-", format: false },
});

const source = args._[0];
if (source == null) {
  console.error("no input file name");
  process.exit(1);
}
parseFile(source)
  .then((data) => {
    const dumps = args.format
      ? JSON.stringify(data, null, 2)
      : JSON.stringify(data);
    if (args.output === "-") {
      console.log(dumps);
    } else {
      const { writeFile } = require("fs").promises;
      return writeFile(output, dumps);
    }
  })
  .catch((e) => {
    console.error(e.toString());
    process.exit(2);
  });

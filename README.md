# Yet Another Configuration Language

"yacl" is a JSON compatible, hcl-like syntax, and human readable configuration language.

A example is like this.

```hcl
foo bar {
  baz = "hello"
}
```
This is equal to this JSON.

```json
{ "foo": { "bar": { "baz": "hello" }}}
```


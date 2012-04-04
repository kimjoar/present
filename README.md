Present
=======

Playing with CSS lexing

How it works:

```javascript
var lexer = new Lexer("h1 { color: #fff; }");
lexer.advance() // returns { type: 'tag', line: 1, val: 'h1' }
lexer.advance() // returns { type: 'whitespace', line: 1, val: ' ' }
lexer.advance() // returns { type: '{', line: 1 }
lexer.advance() // returns { type: 'whitespace', line: 1, val: ' ' }
lexer.advance() // returns { type: 'property', line: 1, val: 'color' }
lexer.advance() // returns { type: ':', line: 1 }
lexer.advance() // returns { type: 'whitespace', line: 1, val: ' ' }
lexer.advance() // returns { type: 'color', line: 1, val: '#fff' }
lexer.advance() // returns { type: ';', line: 1 }
lexer.advance() // returns { type: 'whitespace', line: 1, val: ' ' }
lexer.advance() // returns { type: '}', line: 1 }
lexer.advance() // returns { type: 'eos', line: 1 }
```

Run tests:

    make test

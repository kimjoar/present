Lexer = require('../lib/lexer')
should = require('should')

ensureToken = (opts) ->
  opts.func = opts.type unless opts.func
  lexer = new Lexer(opts.input)
  out = lexer[opts.func].apply lexer
  out.should.have.property('type', opts.type)
  out.should.have.property('val', opts.val) if opts.val

advanceTokens = (string, tokens) ->
  lexer = new Lexer(string)
  lexer.advance().should.have.property('type', type) for type in tokens

describe "Lexer", ->
  describe "eos", ->
    it "returns eos token if at end-of-source", ->
      ensureToken
        input: ""
        type:  "eos"

    it "returns undefined if not at end-of-source", ->
      lexer = new Lexer("#test {}")
      should.not.exist(lexer.eos())

  describe "tag", ->
    it "returns tag token if proper tag selector", ->
      ensureToken
        input: "h1"
        type:  "tag"
        val:   "h1"

  describe "pseudo", ->
    it "returns pseudo token if proper pseudo-class", ->
      ensureToken
        input: ":hover"
        type:  "pseudo"
        val:   "hover"

    it "returns pseudo token if pseudo-class contains -", ->
      ensureToken
        input: ":first-line"
        type:  "pseudo"
        val:   "first-line"

  describe "id", ->
    it "returns id token if proper id selector", ->
      ensureToken
        input: "#test"
        type:  "id"
        val:   "test"

    it "does not include ' ' in id", ->
      ensureToken
        input: "#test p"
        type:  "id"
        val:   "test"

  describe "className", ->
    it "returns class token if proper class selector", ->
      ensureToken
        input: ".test"
        type:  "class"
        func:  "className"
        val:   "test"

  describe "braces", ->
    it "returns start braces token if a start braces is present", ->
      ensureToken
        input: "{"
        type:  "startBraces"
        func:  "braces"

    it "returns end braces token if an end braces is present", ->
      ensureToken
        input: "}"
        type:  "endBraces"
        func:  "braces"

  describe "property", ->
    it "returns a property token if proper property", ->
      lexer = new Lexer("background-color:")
      lexer.property().should.have.property('type', 'property')
      lexer.deferred().should.have.property('type', ':')

    it "returns a property token if browser specific property", ->
      lexer = new Lexer("-webkit-box-shadow:")
      lexer.property().should.have.property('type', 'property')
      lexer.deferred().should.have.property('type', ':')

    it "returns correct value if proper property", ->
      ensureToken
        input: "background-color:"
        type:  "property"
        val:   "background-color"

  describe "colon", ->
    it "returns colon token if single colon", ->
      ensureToken
        input: ":"
        type:  ":"
        func:  "colon"

  describe "comma", ->
    it "returns comma token if single comma", ->
      ensureToken
        input: ","
        type:  ","
        func:  "comma"

  describe "percent", ->
    it "returns percent token if single percent", ->
      ensureToken
        input: "%"
        type:  "%"
        func:  "percent"

  describe "identifier", ->
    it "handles single-word value as identifier", ->
      ensureToken
        input: "Times"
        type:  "identifier"
        val:   "Times"

  describe "string", ->
    it "handles space separated strings", ->
      ensureToken
        input: '"New Century Schoolbook"'
        type:  "string"
        val:   '"New Century Schoolbook"'

    it "handles strings with _", ->
      ensureToken
        input: "'_test'"
        type:  "string"
        val:   "'_test'"

  describe "number", ->
    it "handles 0-9 one or more times as a number", ->
      ensureToken
        input: "123"
        type:  "number"
        val:   "123"

    it "handles number containing .", ->
      ensureToken
        input: "12.3"
        type:  "number"
        val:   "12.3"

  describe "color", ->
    it "handles shortened hex colors", ->
      ensureToken
        input: "#fff"
        type:  "color"
        val:   "#fff"

    it "handles regular hex colors", ->
      ensureToken
        input: "#abc123"
        type:  "color"
        val:   "#abc123"

  describe "value", ->
    it "handles ()", ->
      ensureToken
        input: "white url(candybar.gif)"
        type:  "value"
        val:   "white url(candybar.gif)"

    it "handles %", ->
      ensureToken
        input: "200%"
        type:  "value"
        val:   "200%"

    it "does not include ;", ->
      ensureToken
        input: "200%;"
        type:  "value"
        val:   "200%"

    it "does not include !", ->
      ensureToken
        input: "200% !important"
        type:  "value"
        val:   "200% "

    it "does not include }", ->
      ensureToken
        input: "200%}"
        type:  "value"
        val:   "200%"

  describe "semicolon", ->
    it "returns semicolon token if single semicolon", ->
      ensureToken
        input: ";"
        type:  ";"
        func:  "semicolon"

  describe "!important", ->
    it "returns important token if !important", ->
      ensureToken
        input: "!important"
        type:  "important"

  describe "newline", ->
    it "returns newline token if single newline", ->
      ensureToken
        input: "\n"
        type:  "newline"

    it "increases lineno when matches", ->
      lexer = new Lexer("\n")
      lexer.lineno.should.equal(1)
      lexer.newline()
      lexer.lineno.should.equal(2)

    it "does not increase lineno when no match", ->
      lexer = new Lexer("test")
      lexer.lineno.should.equal(1)
      lexer.newline()
      lexer.lineno.should.equal(1)

  describe "comment", ->
    it "handles comment on one line", ->
      ensureToken
        input: '/* testing */'
        type:  'comment'
        val:   '/* testing */'

  describe "advance", ->
    it 'should find pseudo selector in "p:first-child {color: #fff; }"', ->
      advanceTokens "p:first-child {color: #fff; }",
        ["tag"
         "pseudo"
         "whitespace"]

    it 'should find all tokens in "#test p .good {color: #fff !important;\\nfont: 12px; -webkit-box-shadow: 10px 10px 5px #888; }"', ->
      advanceTokens "#test p .good {color: #fff !important;\nfont: 120%; -webkit-box-shadow: 10px 10px 5px #888;}",
        ['id'
         'whitespace'
         'tag'
         'whitespace'
         'class'
         'whitespace'
         'startBraces'
         'property'
         ':'
         'whitespace'
         'color'
         'whitespace'
         'important'
         ';'
         'newline'
         'property'
         ':'
         'whitespace'
         'number'
         '%'
         ';'
         'whitespace'
         'property'
         ':'
         'whitespace'
         'number'
         'identifier'
         'whitespace'
         'number'
         'identifier'
         'whitespace'
         'number'
         'identifier'
         'whitespace'
         'color'
         ';'
         'endBraces'
         'eos']

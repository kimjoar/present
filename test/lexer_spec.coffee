Lexer = require('../lib/lexer')
should = require('should')

ensure = (opts) ->
  opts.func = opts.type unless opts.func
  lexer = new Lexer(opts.input)
  out = lexer[opts.func].apply lexer
  out.should.have.property('type', opts.type)
  out.should.have.property('val', opts.val) if opts.val

advances = (string, tokens) ->
  lexer = new Lexer(string)
  lexer.advance().should.have.property('type', type) for type in tokens

describe "Lexer", ->
  describe "eos", ->
    it "returns eos token if at end-of-source", ->
      ensure
        input: ""
        type:  "eos"

    it "returns undefined if not at end-of-source", ->
      lexer = new Lexer("#test {}")
      should.not.exist(lexer.eos())

  describe "tag", ->
    it "returns tag token if proper tag selector", ->
      ensure
        input: "h1"
        type:  "tag"
        val:   "h1"

  describe "pseudo", ->
    it "returns pseudo token if proper pseudo-class", ->
      ensure
        input: ":hover"
        type:  "pseudo"
        val:   "hover"

    it "returns pseudo token if pseudo-class contains -", ->
      ensure
        input: ":first-line"
        type:  "pseudo"
        val:   "first-line"

  describe "id", ->
    it "returns id token if proper id selector", ->
      ensure
        input: "#test"
        type:  "id"
        val:   "test"

    it "does not include ' ' in id", ->
      ensure
        input: "#test p"
        type:  "id"
        val:   "test"

  describe "className", ->
    it "returns class token if proper class selector", ->
      ensure
        input: ".test"
        type:  "class"
        func:  "className"
        val:   "test"

  describe "braces", ->
    it "returns start braces token if a start braces is present", ->
      ensure
        input: "{"
        type:  "startBraces"
        func:  "braces"

    it "returns end braces token if an end braces is present", ->
      ensure
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
      ensure
        input: "background-color:"
        type:  "property"
        val:   "background-color"

  describe "colon", ->
    it "returns colon token if single colon", ->
      ensure
        input: ":"
        type:  ":"
        func:  "colon"

  describe "comma", ->
    it "returns comma token if single comma", ->
      ensure
        input: ","
        type:  ","
        func:  "comma"

  describe "percent", ->
    it "returns percent token if single percent", ->
      ensure
        input: "%"
        type:  "%"
        func:  "percent"

  describe "identifier", ->
    it "handles single-word value as identifier", ->
      ensure
        input: "Times"
        type:  "identifier"
        val:   "Times"

  describe "string", ->
    it "handles space separated strings", ->
      ensure
        input: '"New Century Schoolbook"'
        type:  "string"
        val:   '"New Century Schoolbook"'

    it "handles strings with _", ->
      ensure
        input: "'_test'"
        type:  "string"
        val:   "'_test'"

  describe "number", ->
    it "handles 0-9 one or more times as a number", ->
      ensure
        input: "123"
        type:  "number"
        val:   "123"

    it "handles number containing .", ->
      ensure
        input: "12.3"
        type:  "number"
        val:   "12.3"

  describe "color", ->
    it "handles shortened hex colors", ->
      ensure
        input: "#fff"
        type:  "color"
        val:   "#fff"

    it "handles regular hex colors", ->
      ensure
        input: "#abc123"
        type:  "color"
        val:   "#abc123"

  describe "value", ->
    it "handles ()", ->
      ensure
        input: "white url(candybar.gif)"
        type: "value"
        val: "white url(candybar.gif)"

    it "handles %", ->
      ensure
        input: "200%"
        type: "value"
        val: "200%"

    it "does not include ;", ->
      ensure
        input: "200%;"
        type: "value"
        val: "200%"

    it "does not include !", ->
      ensure
        input: "200% !important"
        type: "value"
        val: "200% "

    it "does not include }", ->
      ensure
        input: "200%}"
        type: "value"
        val: "200%"

  describe "semicolon", ->
    it "returns semicolon token if single semicolon", ->
      ensure
        input: ";"
        type: ";"
        func: "semicolon"

  describe "!important", ->
    it "returns important token if !important", ->
      ensure
        input: "!important"
        type: "important"

  describe "newline", ->
    it "returns newline token if single newline", ->
      ensure
        input: "\n"
        type: "newline"

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
      ensure
        input: '/* testing */'
        type: 'comment'
        val: '/* testing */'

  describe "advance", ->
    it 'should find pseudo selector in "p:first-child {color: #fff; }"', ->
      advances "p:first-child {color: #fff; }",
        ["tag"
         "pseudo"
         "whitespace"]

    it 'should find all tokens in "#test p .good {color: #fff !important;\\nfont: 12px; -webkit-box-shadow: 10px 10px 5px #888; }"', ->
      advances "#test p .good {color: #fff !important;\nfont: 120%; -webkit-box-shadow: 10px 10px 5px #888;}",
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

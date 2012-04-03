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

    it "returns tag token if *", ->
      ensureToken
        input: "*"
        type:  "tag"
        val:   "*"

  describe "pseudo", ->
    it "returns pseudo token if pseudo class", ->
      ensureToken
        input: ":hover"
        type:  "pseudo"
        val:   ":hover"

    it "returns pseudo token if pseudo class contains -", ->
      ensureToken
        input: ":first-line"
        type:  "pseudo"
        val:   ":first-line"

    it "returns pseudo token if pseudo element", ->
      ensureToken
        input: "::after"
        type:  "pseudo"
        val:   "::after"

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

  describe "bracket", ->
    it "returns bracket token if start bracket", ->
      ensureToken
        input: "["
        type:  "["
        func:  "bracket"

    it "returns bracket token if end bracket", ->
      ensureToken
        input: "]"
        type:  "]"
        func:  "bracket"

  describe "equal", ->
    it "returns equal token if =", ->
      ensureToken
        input: "="
        type:  "="
        func:  "equal"

    it "returns includes token if =", ->
      ensureToken
        input: "~="
        type:  "~="
        func:  "includes"

    it "returns dashmatch token if |=", ->
      ensureToken
        input: "|="
        type:  "|="
        func:  "dashmatch"

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

    it "handles '-' in identifier", ->
      ensureToken
        input: "ff-tisa-web-pro"
        type:  "identifier"
        val:   "ff-tisa-web-pro"

    it "handles numbers in identifiers", ->
      ensureToken
        input: "tisapro1",
        type:  "identifier"
        val:   "tisapro1"

  describe "string", ->
    it "handles space separated strings", ->
      ensureToken
        input: '"New Century Schoolbook"'
        type:  "string"
        val:   '"New Century Schoolbook"'

    it "handles strings with special characters", ->
      ensureToken
        input: '"_#!/%^&"'
        type:  "string"
        val:   '"_#!/%^&"'

    it "handles strings in '", ->
      ensureToken
        input: "'New Century Schoolbook'"
        type:  "string"
        val:   "'New Century Schoolbook'"

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

    it "handles negative numbers", ->
      ensureToken
        input: "-2"
        type:  "number"
        val:   "-2"

  describe "color", ->
    it "handles shortened hex colors", ->
      ensureToken
        input: "#fff"
        type:  "color"
        val:   "#fff"

    it "handles rgb", ->
      ensureToken
        input: "rgb(255,0,0)"
        type:  "color"
        val:   "rgb(255,0,0)"

    it "handles rgb with %", ->
      ensureToken
        input: "rgb(100%, 20%, 0)"
        type:  "color"
        val:   "rgb(100%, 20%, 0)"

    it "handles rgba", ->
      ensureToken
        input: "rgba(0,255,0,0.1)"
        type:  "color"
        val:   "rgba(0,255,0,0.1)"

    it "handles hsl", ->
      ensureToken
        input: "hsl(360,10%,0%)"
        type:  "color"
        val:   "hsl(360,10%,0%)"

    it "handles hsla", ->
      ensureToken
        input: "rgba(0,50%,0%,0.1)"
        type:  "color"
        val:   "rgba(0,50%,0%,0.1)"

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

  describe "at-rule", ->
    ensureAtRuleToken = (name) ->
      ensureToken
        input: "@#{name}"
        type:  "atRule"
        val:   "@#{name}"

    it "handles @import",    -> ensureAtRuleToken "import"
    it "handles @charset",   -> ensureAtRuleToken "charset"
    it "handles @font-face", -> ensureAtRuleToken "font-face"
    it "handles @media",     -> ensureAtRuleToken "media"

  describe "advance", ->
    it 'should handle pseudo selector', ->
      advanceTokens "p:first-child {color: #fff; }",
        ["tag"
         "pseudo"
         "whitespace"]

    it 'should handle brackets', ->
      advanceTokens "p[test] {color: #fff; }",
        ["tag"
         "["
         "identifier",
         "]"]

    it 'should handle match in brackets', ->
      advanceTokens 'p[test="what"] {color: #fff; }',
        ["tag"
         "["
         "identifier",
         "=",
         "string",
         "]"]

    it 'should handle at-rules', ->
      advanceTokens '@charset "utf-8"',
        ["atRule"
         "whitespace"
         "string"
         "eos"]

    it 'should handle *', ->
      advanceTokens '* html { color: #fff; }',
        ["tag",
         "whitespace",
         "tag",
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

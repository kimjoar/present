Lexer = require('../')
should = require('should')

ensureToken = (opts) ->
  opts.func = opts.type unless opts.func
  lexer = new Lexer(opts.input)
  out = lexer[opts.func].apply lexer
  out.should.have.property('type', opts.type)
  out.should.have.property('val', opts.val) if opts.val

ensureTokenType = (type, val) ->
  ensureToken
    input: val
    type:  type
    val:   val

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

  describe "selectors", ->
    describe "universal selector", ->
      it "returns universal token if *", ->
        ensureToken
          input: "*"
          type:  "universal"

    describe "type selectors", ->
      it "returns element token if element selector", ->
        ensureToken
          input: "h1"
          type:  "element"
          val:   "h1"

    describe "class selectors", ->
      it "returns class token if class selector", ->
        ensureToken
          input: ".test"
          type:  "class"
          func:  "className"
          val:   "test"

    describe "id selectors", ->
      it "returns id token if id selector", ->
        ensureToken
          input: "#test"
          type:  "id"
          val:   "test"

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

    it "returns includes token if ~=", ->
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
    ensureColorToken = (val) ->
      ensureTokenType "color", val

    it "handles shortened hex colors", ->
      ensureColorToken "#fff"

    it "handles rgb", ->
      ensureColorToken "rgb(255,0,0)"

    it "handles rgb with %", ->
      ensureColorToken "rgb(100%, 20%, 0)"

    it "handles rgba", ->
      ensureColorToken "rgba(0,255,0,0.1)"

    it "handles hsl", ->
      ensureColorToken "hsl(360,10%,0%)"

    it "handles hsla", ->
      ensureColorToken "rgba(0,50%,0%,0.1)"

    it "handles regular hex colors", ->
      ensureColorToken "#abc123"

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
        input: '/* *testing */'
        type:  'comment'
        val:   '/* *testing */'

    it "handles multiline comment", ->
      comment = """
               /* this is a
                  long comment! */
               """

      ensureTokenType 'comment', comment

  describe "at-rule", ->
    ensureAtRuleToken = (name) ->
      ensureTokenType "atRule", "@#{name}"

    it "handles @import",    -> ensureAtRuleToken "import"
    it "handles @charset",   -> ensureAtRuleToken "charset"
    it "handles @font-face", -> ensureAtRuleToken "font-face"
    it "handles @media",     -> ensureAtRuleToken "media"

  describe "whitespace", ->
    it "handles tabs", ->
      ensureTokenType "tab", "\t"

  describe "url", ->
    it "should handle urls within '", ->
      ensureToken
        input: "url('../images/template/topNavigation_domainLevel.gif')"
        type:  "url"
        val:   "'../images/template/topNavigation_domainLevel.gif'"

    it "should handle urls within '", ->
      ensureToken
        input: 'url("../images/template/topNavigation_domainLevel.gif")'
        type:  "url"
        val:   '"../images/template/topNavigation_domainLevel.gif"'

    it "should handle bare urls", ->
      ensureToken
        input: "url(../images/template/topNavigation_domainLevel.gif)"
        type:  "url"
        val:   "../images/template/topNavigation_domainLevel.gif"

  describe "combinators", ->
    it "should handle adjacent siblings selector (+)", ->
      ensureToken
        input: "+"
        func:  "adjacentSibling"
        type:  "+"

    it "should handle general siblings selector (~)", ->
      ensureToken
        input: "~"
        func:  "generalSibling"
        type:  "~"

    it "should handle child selector (>)", ->
      ensureToken
        input: ">"
        func:  "child"
        type:  ">"

  describe "lookahead", ->
    it "should be able to look ahead 1 token", ->
      lexer = new Lexer("h1 {}")
      token = lexer.lookahead(1)
      token.should.have.property("type", "element")

    it "should be able to look ahead more than one token", ->
      lexer = new Lexer("h1 {}")
      token = lexer.lookahead(3)
      token.should.have.property("type", "startBraces")

    it "should not break advance", ->
      lexer = new Lexer("h1 {}")
      lexer.lookahead(1)
      token = lexer.advance()
      token.should.have.property("type", "element")

  describe "peek", ->
    it "should look ahead 1 token", ->
      lexer = new Lexer("h1 {}")
      token = lexer.peek()
      token.should.have.property("type", "element")

  describe "advance", ->
    it 'should handles tabs', ->
      advanceTokens "h1\t{}",
        ["element"
         "tab"
         "startBraces"
         "endBraces"
         "eos"]

    it 'should handle pseudo selector', ->
      advanceTokens "p:first-child {color: #fff; }",
        ["element"
         "pseudo"
         "whitespace"]

    it 'should handle brackets', ->
      advanceTokens "p[test] {color: #fff; }",
        ["element"
         "["
         "identifier",
         "]"]

    it 'should handle match in brackets', ->
      advanceTokens 'p[test="what"] {color: #fff; }',
        ["element"
         "["
         "identifier",
         "=",
         "string",
         "]"]

    it 'should handle several comments', ->
      advanceTokens '/* test */ a {} /* again */',
        ["comment",
         "whitespace"
         "element"
         "whitespace"
         "startBraces"
         "endBraces"
         "whitespace"
         "comment"
         "eos"]

    it 'should handle at-rules', ->
      advanceTokens '@charset "utf-8"',
        ["atRule"
         "whitespace"
         "string"
         "eos"]

    it 'should handle *', ->
      advanceTokens '* html { color: #fff; }',
        ["universal",
         "whitespace",
         "element",
         "whitespace"]

    it 'should find all tokens in "#test p .good {color: #fff !important;\\nfont: 12px; -webkit-box-shadow: 10px 10px 5px #888; }"', ->
      advanceTokens "#test p .good {color: #fff !important;\nfont: 120%; -webkit-box-shadow: 10px 10px 5px #888;}",
        ['id'
         'whitespace'
         'element'
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

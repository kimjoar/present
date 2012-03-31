Lexer = require('../lib/lexer')
should = require('should')

describe "Lexer", ->
  describe "eos", ->
    it "returns eos token if at end-of-source", ->
      lexer = new Lexer("")
      lexer.eos().should.have.property('type', 'eos')

    it "returns undefined if not at end-of-source", ->
      lexer = new Lexer("#test {}")
      should.not.exist(lexer.eos())

  describe "tag", ->
    it "returns tag token if proper tag selector", ->
      lexer = new Lexer("h1")
      lexer.tag().should.have.property('type', 'tag')

    it "returns correct value if proper tag selector", ->
      lexer = new Lexer("h1")
      lexer.tag().should.have.property('val', 'h1')

  describe "pseudo", ->
    it "returns pseudo token if proper pseudo-class", ->
      lexer = new Lexer(":hover")
      lexer.pseudo().should.have.property('type', 'pseudo')

    it "returns pseudo token if pseudo-class contains -", ->
      lexer = new Lexer(":first-line")
      pseudo = lexer.pseudo()
      pseudo.should.have.property('type', 'pseudo')
      pseudo.should.have.property('val', 'first-line')

    it "returns correct value if tag with pseudo-class", ->
      lexer = new Lexer(":hover")
      lexer.pseudo().should.have.property('val', 'hover')

  describe "id", ->
    it "returns id token if proper id selector", ->
      lexer = new Lexer("#test")
      lexer.id().should.have.property('type', 'id')

    it "returns correct value if proper id selector", ->
      lexer = new Lexer("#test")
      lexer.id().should.have.property('val', 'test')

    it "does not include ' ' in id", ->
      lexer = new Lexer("#test p")
      lexer.id().should.have.property('val', 'test')

  describe "className", ->
    it "returns class token if proper class selector", ->
      lexer = new Lexer(".test")
      lexer.className().should.have.property('type', 'class')

    it "returns correct value if proper class selector", ->
      lexer = new Lexer(".test")
      lexer.className().should.have.property('val', 'test')

  describe "braces", ->
    it "returns start braces token if a start braces is present", ->
      lexer = new Lexer("{")
      lexer.braces().should.have.property('type', 'startBraces')

    it "returns end braces token if an end braces is present", ->
      lexer = new Lexer("}")
      lexer.braces().should.have.property('type', 'endBraces')

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
      lexer = new Lexer("background-color:")
      lexer.property().should.have.property('val', 'background-color')

  describe "colon", ->
    it "returns colon token if single colon", ->
      lexer = new Lexer(":")
      lexer.colon().should.have.property('type', ':')

  describe "comma", ->
    it "returns comma token if single comma", ->
      lexer = new Lexer(",")
      lexer.comma().should.have.property('type', ',')

  describe "percent", ->
    it "returns percent token if single percent", ->
      lexer = new Lexer("%")
      lexer.percent().should.have.property('type', '%')

  describe "identifier", ->
    it "handles single-word value as identifier", ->
      lexer = new Lexer("Times")
      identifier = lexer.identifier()
      identifier.should.have.property('type', 'identifier')
      identifier.should.have.property('val', 'Times')

  describe "string", ->
    it "handles space separated strings", ->
      lexer = new Lexer('"New Century Schoolbook"')
      string = lexer.string()
      string.should.have.property('type', 'string')
      string.should.have.property('val', '"New Century Schoolbook"')

    it "handles strings with _", ->
      lexer = new Lexer("'_test'")
      string = lexer.string()
      string.should.have.property('type', 'string')
      string.should.have.property('val', "'_test'")

  describe "number", ->
    it "handles 0-9 one or more times as a number", ->
      lexer = new Lexer("123")
      number = lexer.number()
      number.should.have.property('type', 'number')
      number.should.have.property('val', "123")

    it "handles number containing .", ->
      lexer = new Lexer("12.3")
      number = lexer.number()
      number.should.have.property('type', 'number')
      number.should.have.property('val', "12.3")

  describe "color", ->
    it "handles shortened hex colors", ->
      lexer = new Lexer("#fff")
      color = lexer.color()
      color.should.have.property('type', 'color')
      color.should.have.property('val', '#fff')

    it "handles regular hex colors", ->
      lexer = new Lexer("#abc123")
      color = lexer.color()
      color.should.have.property('type', 'color')
      color.should.have.property('val', '#abc123')

  describe "value", ->
    it "handles ()", ->
      lexer = new Lexer("white url(candybar.gif)")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', 'white url(candybar.gif)')

    it "handles %", ->
      lexer = new Lexer("200%")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', '200%')

    it "does not include ;", ->
      lexer = new Lexer("200%;")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', '200%')

    it "does not include !", ->
      lexer = new Lexer("200% !important")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', '200% ')

    it "does not include }", ->
      lexer = new Lexer("200%}")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', '200%')

  describe "semicolon", ->
    it "returns semicolon token if single semicolon", ->
      lexer = new Lexer(";")
      lexer.semicolon().should.have.property('type', ';')

  describe "newline", ->
    it "returns newline token if single newline", ->
      lexer = new Lexer("\n")
      lexer.newline().should.have.property('type', 'newline')

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

  describe "advance", ->
    it 'should find all tokens in "#test p .good {color: #fff;\\nfont: 12px; -webkit-box-shadow: 10px 10px 5px #888; }"', ->
      lexer = new Lexer("#test p .good {color: #fff;\nfont: 120%; -webkit-box-shadow: 10px 10px 5px #888;}")
      lexer.advance().should.have.property('type', 'id')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'tag')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'class')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'startBraces')
      lexer.advance().should.have.property('type', 'property')
      lexer.advance().should.have.property('type', ':')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'color')
      lexer.advance().should.have.property('type', ';')
      lexer.advance().should.have.property('type', 'newline')
      lexer.advance().should.have.property('type', 'property')
      lexer.advance().should.have.property('type', ':')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'number')
      lexer.advance().should.have.property('type', '%')
      lexer.advance().should.have.property('type', ';')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'property')
      lexer.advance().should.have.property('type', ':')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'number')
      lexer.advance().should.have.property('type', 'identifier')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'number')
      lexer.advance().should.have.property('type', 'identifier')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'number')
      lexer.advance().should.have.property('type', 'identifier')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'color')
      lexer.advance().should.have.property('type', ';')
      lexer.advance().should.have.property('type', 'endBraces')
      lexer.advance().should.have.property('type', 'eos')

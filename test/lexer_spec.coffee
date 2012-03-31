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

  describe "value", ->
    it "handles single-word value", ->
      lexer = new Lexer("Times")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', 'Times')

    it "handles comma-separated words", ->
      lexer = new Lexer("Times, serif")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', 'Times, serif')

    it "handles \"", ->
      lexer = new Lexer('"New Century Schoolbook"')
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', '"New Century Schoolbook"')

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

    it "handles #", ->
      lexer = new Lexer("#fff")
      value = lexer.value()
      value.should.have.property('type', 'value')
      value.should.have.property('val', '#fff')

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

  describe "advance", ->
    it 'should find all tokens in "#test p .good {color: #fff;\\nfont: 12px; -webkit-box-shadow: 10px 10px 5px #888; }"', ->
      lexer = new Lexer("#test p .good {color: #fff;\nfont: 12px; -webkit-box-shadow: 10px 10px 5px #888;}")
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
      lexer.advance().should.have.property('type', 'value')
      lexer.advance().should.have.property('type', ';')
      lexer.advance().should.have.property('type', 'newline')
      lexer.advance().should.have.property('type', 'property')
      lexer.advance().should.have.property('type', ':')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'value')
      lexer.advance().should.have.property('type', ';')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'property')
      lexer.advance().should.have.property('type', ':')
      lexer.advance().should.have.property('type', 'whitespace')
      lexer.advance().should.have.property('type', 'value')
      lexer.advance().should.have.property('type', ';')
      lexer.advance().should.have.property('type', 'endBraces')
      lexer.advance().should.have.property('type', 'eos')

Present = require('../')
should = require('should')

Parser = Present.Parser
nodes = Present.nodes

describe "Parser", ->
  describe "expect", ->
    it "advances when type matches next token", ->
      parser = new Parser("h1")
      token = parser.expect("element")
      token.should.have.property('type', 'element')

    it "throws an error if type does not match next token", ->
      parser = new Parser("h1")
      (() -> parser.expect("class")).should.throw(/Expected type 'class'/i)

  describe "parse", ->
    it "returns a stylesheet", ->
      parser = new Parser("h1")
      sheet = parser.parse()
      sheet.should.be.an.instanceof(nodes.Stylesheet)

  describe "parseRule", ->
    checkRule = (input, type) ->
      parser = new Parser(input)
      rule = parser.parseRule()
      rule.nodes[0].type.should.equal(type)

    it "handles elements", -> checkRule "h1", "element"
    it "handles ids", -> checkRule "#test", "id"
    it "handles classes", -> checkRule ".test", "class"
    it "handles whitespace", ->
      checkRule " .class", "whitespace"
      checkRule "\t.class", "tab"

    it "throws an error if token is unexpected", ->
      parser = new Parser("property: value")
      (() -> parser.parseRule()).should.throw(/unexpected type/i)


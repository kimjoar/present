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

    it "handles unexpected types", ->
      parser = new Parser("property: value")
      (() -> parser.parse()).should.throw(/Unexpected type/i)

    it "handles @charset", ->
      parser = new Parser('@charset "UTF-8";')
      sheet = parser.parse()
      sheet.nodes[0].should.be.an.instanceof(nodes.Charset)
      sheet.nodes[0].val.should.equal('"UTF-8"')

  describe "parseRule", ->
    ensureSelector = (input) ->
      parser = new Parser(input)
      rule = parser.parseRule()
      isSelector(rule.nodes[0])

    isSelector = (node) ->
      node.should.be.an.instanceof(nodes.Selector)

    it "handles elements", -> ensureSelector "h1"
    it "handles ids", -> ensureSelector "#test"
    it "handles classes", -> ensureSelector ".test"

    it "does not allow only whitespace", ->
      parser = new Parser(" ")
      (() -> parser.parseRule()).should.throw(/empty selector/i)
      parser = new Parser("\t")
      (() -> parser.parseRule()).should.throw(/empty selector/i)

    it "handles selector with several simple selectors", ->
      parser = new Parser("h1 h2")
      rule = parser.parseRule()
      rule.nodes.length.should.equal(1)
      rule.nodes[0].nodes.length.should.equal(3)

    it "handles several selectors", ->
      parser = new Parser("h1,h2")
      rule = parser.parseRule()
      ruleNodes = rule.nodes
      ruleNodes.length.should.equal(3)
      isSelector(ruleNodes[0])
      isSelector(ruleNodes[2])

    it "throws an error if token is unexpected", ->
      parser = new Parser("property: value")
      (() -> parser.parseRule()).should.throw(/unexpected type/i)

    it "does not allow empty selector", ->
      parser = new Parser("h1,")
      (() -> parser.parseRule()).should.throw(/empty selector/i)

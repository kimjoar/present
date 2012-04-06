Parser = require('../lib/parser')
nodes = require('../lib/nodes')
should = require('should')

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

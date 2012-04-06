Lexer = require('./lexer')
nodes = require('./nodes')

Parser = module.exports = (str, filename, options) ->
  this.input = str
  this.lexer = new Lexer(str, options)
  this.filename = filename
  this.options = options

Parser.prototype =
  #
  # Proxy to lexer
  #
  peek: -> this.lexer.peek()
  advance: -> this.lexer.advance()

  #
  # Expect the given type, or throw an exception.
  #
  expect: (type) ->
    if this.peek().type == type
      this.advance();
    else
      throw new Error("Expected type '#{type}', got '#{this.peek().type}'")

  #
  # Parse input returning a string of js for evaluation.
  #
  parse: ->
    this.sheet = new nodes.Stylesheet()

    while 'eos' != this.peek().type
      this.sheet.push(this.parseRule())

    this.sheet

  #
  # selectors+ { declarations* }
  #
  parseRule: ->
    switch this.peek().type
      when "element" then this.parseElement()

  parseElement: ->
    this.advance()
    "element"

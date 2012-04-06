Lexer = require('./lexer')
nodes = require('./nodes')

Parser = module.exports = (str, filename, options) ->
  this.input = str
  this.lexer = new Lexer(str, options)
  this.filename = filename
  this.options = options

Parser.prototype =
  expect: (type) ->
    if this.lexer.peek().type == type
      this.lexer.advance();
    else
      throw new Error("Expected type '#{type}', got '#{this.lexer.peek().type}'")

  #
  # Parse input returning a string of js for evaluation.
  #
  parse: () ->
    this.sheet = new nodes.Stylesheet()

    while 'eos' != this.lexer.peek().type
      this.sheet.push(this.parseRule())

    this.sheet

  #
  # selectors+ { declarations* }
  #
  parseRule: () ->
    switch this.lexer.peek().type
      when "element" then this.parseElement()

  parseElement: () ->
    this.lexer.advance()
    "element"

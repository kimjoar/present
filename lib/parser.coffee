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
  # stylesheet
  # - rule
  #   - selectors
  #   - declaration block
  #     - declarations
  #       - property
  #       - value
  #
  parseRule: ->
    rule = new nodes.Rule()

    while '{' != this.peek().type && 'eos' != this.peek().type
      switch this.peek().type
        when 'element' then rule.push(this.advance())
        when 'id' then rule.push(this.advance())
        when 'class' then rule.push(this.advance())
        when 'whitespace' then rule.push(this.advance())
        when 'tab' then rule.push(this.advance())
        else throw new Error("Unexpected type '#{this.peek().type}'")

    rule

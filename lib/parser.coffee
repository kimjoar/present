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
  lookahead: (n) -> this.lexer.lookahead(n)

  #
  # Expect the given `type`, or throw an exception.
  #
  expect: (type) ->
    if this.peek().type == type
      this.advance();
    else
      throw new Error("Expected type '#{type}', got '#{this.peek().type}'")

  #
  # Accept the given `type`
  #
  accept: (type) ->
    if this.peek().type == type
      this.advance()

  #
  # Parse input returning a string of js for evaluation.
  #
  parse: ->
    this.sheet = new nodes.Stylesheet()

    this.parseCharset() if this.hasCharset()

    while 'eos' != this.peek().type
      this.sheet.push(this.parseRule())

    this.sheet

  hasCharset: ->
    this.peek().type == "atRule" &&
      this.lookahead(2).type == "whitespace" &&
      this.lookahead(3).type == "string"

  parseCharset: () ->
    this.expect("atRule")
    this.expect("whitespace")
    charset = this.expect("string")
    this.sheet.push(new nodes.Charset(charset.val))
    this.accept(";")

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
    selector = new nodes.Selector()

    while '{' != this.peek().type && 'eos' != this.peek().type
      switch this.peek().type
        when 'element', 'id', 'class'
          selector.push(this.advance())
        when 'whitespace', 'tab'
          selector.push(new nodes.Node(this.advance()))
        when ','
          rule.push(selector)
          rule.push(new nodes.Node(this.advance()))
          selector = new nodes.Selector()
        else throw new Error("Unexpected type '#{this.peek().type}'")

    if selector.nodes.length == 0
      throw new Error("empty selector")

    rule.push(selector)
    rule

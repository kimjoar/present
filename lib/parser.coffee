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

  parse: ->
    sheet = new nodes.Stylesheet()

    while 'eos' != this.peek().type
      sheet.push(this.parseStylesheet())

    sheet

  parseStylesheet: ->
    switch this.peek().type
      when 'charset' then this.parseCharset()
      when 'element', 'id', 'class' then this.parseRule()
      else throw new Error("Unexpected type '#{this.peek().type}'")

  parseCharset: () ->
    this.expect("charset")
    this.expect("whitespace")
    charset = this.expect("string")
    this.accept(";")
    new nodes.Charset(charset.val)

  parseRule: ->
    rule = new nodes.Rule()

    while '{' != this.peek().type && 'eos' != this.peek().type
      switch this.peek().type
        when 'element', 'id', 'class'
          rule.push(this.parseSelector())
        when 'whitespace', 'tab'
          rule.push(this.tokenNode())
        when ','
          rule.push(this.tokenNode())
        else throw new Error("Unexpected type '#{this.peek().type}'")

    rule

  tokenNode: ->
    new nodes.Node(this.advance())

  parseSelector: ->
    selector = new nodes.Selector()

    while '{' != this.peek().type && ',' != this.peek().type && 'eos' != this.peek().type
      switch this.peek().type
        when 'element', 'id', 'class'
          selector.push(this.advance())
        when 'whitespace', 'tab'
          selector.push(this.tokenNode())
        else throw new Error("Unexpected type '#{this.peek().type}'")

    selector

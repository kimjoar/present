Lexer = require('./lexer')
nodes = require('./nodes')

Parser = module.exports = (str, filename, options) ->
  @input = str
  @lexer = new Lexer(str, options)
  @filename = filename
  @options = options

Parser.prototype =
  #
  # Proxy to lexer
  #
  peek: -> @lexer.peek()
  advance: -> @lexer.advance()
  lookahead: (n) -> @lexer.lookahead(n)

  #
  # Expect the given `type`, or throw an exception.
  #
  expect: (type) ->
    if @peek().type == type
      @advance();
    else
      throw new Error("Expected type '#{type}', got '#{@peek().type}'")

  #
  # Accept the given `type`
  #
  accept: (type) ->
    if @peek().type == type
      @advance()

  parse: ->
    sheet = new nodes.Stylesheet()

    while 'eos' != @peek().type
      sheet.push(@parseStylesheet())

    sheet

  whitespace: ->
    new nodes.Node(this.accept('whitespace') or this.accept('tab'))

  parseStylesheet: ->
    switch @peek().type
      when 'charset' then @parseCharset()
      when 'element', 'id', 'class' then @parseRule()
      when 'whitespace', 'tab' then @whitespace()
      else throw new Error("Unexpected type '#{@peek().type}'")

  parseCharset: () ->
    @expect("charset")
    @expect("whitespace")
    charset = @expect("string")
    @accept(";")
    new nodes.Charset(charset.val)

  parseRule: ->
    rule = new nodes.Rule()
    hasSelector = false

    while '{' != @peek().type && 'eos' != @peek().type
      switch @peek().type
        when 'element', 'id', 'class'
          rule.push(@parseSelector())
          hasSelector = true
        when 'whitespace', 'tab'
          rule.push(@tokenNode())
        when ','
          rule.push(@tokenNode())
          hasSelector = false
        else throw new Error("Unexpected type '#{@peek().type}'")

    unless hasSelector
      throw new Error("Empty selector")

    rule

  tokenNode: ->
    new nodes.Node(@advance())

  parseSelector: ->
    selector = new nodes.Selector()

    while '{' != @peek().type && ',' != @peek().type && 'eos' != @peek().type
      switch @peek().type
        when 'element', 'id', 'class'
          selector.push(@advance())
        when 'whitespace', 'tab'
          selector.push(@tokenNode())
        else throw new Error("Unexpected type '#{@peek().type}'")

    selector

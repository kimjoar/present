Lexer = module.exports = (str, options) ->
  options || (options = {})
  this.input = str.replace(/\r\n|\r/g, '\n')
  this.lineno = 1
  this.deferredTokens = []
  this.inBraces = false
  this.inBrackets = false

Lexer.prototype =
  #
  # Construct a token with the given `type` and `val`.
  #
  token: (type, val) ->
    {
      type: type
      line: this.lineno
      val: val
    }

  #
  # Consume the given `len` of input, i.e. we are finished with it.
  #
  consume: (len) ->
    this.input = this.input.substr(len)

  #
  # Scan for `type` with the given `regexp`.
  #
  scan: (regexp, type) ->
    if captures = regexp.exec(this.input)
      # When we find a match, we consume it and create a token
      this.consume(captures[0].length)
      this.token(type, captures[1])

  #
  # end-of-source
  #
  eos: ->
    return if this.input.length
    this.token('eos')

  #
  # tag selector
  #
  tag: ->
    return if this.inBraces or this.inBrackets
    this.scan(/^(\*|\w+)/, 'tag')

  #
  # @charset
  #
  charset: ->
    this.scan(/^@charset/, 'charset')

  #
  # pseudo-class
  #
  pseudo: ->
    this.scan(/^:([\w-]+)/, 'pseudo')

  #
  # braces
  #
  braces: ->
    if captures = /^{/.exec(this.input)
      this.inBraces = true
      this.consume(captures[0].length)
      this.token('startBraces', captures[1])
    else if captures = /^}/.exec(this.input)
      this.inBraces = false
      this.consume(captures[0].length)
      this.token('endBraces', captures[1])

  #
  # brackets
  #
  bracket: ->
    if captures = /^\[/.exec(this.input)
      this.inBrackets = true
      this.consume(captures[0].length)
      this.token('[', captures[1])
    else if captures = /^\]/.exec(this.input)
      this.inBrackets = false
      this.consume(captures[0].length)
      this.token(']', captures[1])

  #
  # id selector
  #
  id: ->
    return if this.inBraces
    this.scan(/^#([\w-]+)/, 'id')

  #
  # class selector
  #
  className: ->
    return if this.inBraces
    this.scan(/^\.([\w-]+)/, 'class')

  #
  # property
  #
  property: ->
    if captures = /^([\w-]+):/.exec(this.input)
      this.consume(captures[0].length)
      this.defer(this.token(':'))
      this.token('property', captures[1])

  equal: ->
    this.scan(/^=/, "=")

  includes: ->
    this.scan(/^~=/, "~=")

  dashmatch: ->
    this.scan(/^\|=/, "|=")

  colon: ->
    this.scan(/^:/, ":")

  semicolon: ->
    this.scan(/^;/, ";")

  comma: ->
    this.scan(/^,/, ",")

  percent: ->
    this.scan(/^%/, "%")

  identifier: ->
    this.scan(/^([a-zA-Z]+)/, 'identifier')

  value: ->
    this.scan(/^([^;!}]+)/, 'value')

  string: ->
    this.scan(/^(\"[^\"]+\"|\'[^\']+\')/, 'string')

  number: ->
    this.scan(/^([0-9\.]+)/, 'number')

  color: ->
    this.scan(/^(#[0-9a-fA-F]{3,6})/, 'color')

  important: ->
    this.scan(/^!important/, 'important');

  whitespace: ->
    this.scan(/^([ ]+)/, 'whitespace')

  comment: ->
    this.scan(/^(\/\*.+\*\/)/, 'comment')

  newline: ->
    if newline = this.scan(/^(\n)/, 'newline')
      this.lineno += 1
      newline

  advance: ->
    this.next()

  next: ->
    this.deferred()     or
      this.comment()    or
      this.pseudo()     or
      this.id()         or
      this.charset()    or
      this.whitespace() or
      this.newline()    or
      this.braces()     or
      this.bracket()    or
      this.equal()      or
      this.includes()   or
      this.dashmatch()  or
      this.tag()        or
      this.className()  or
      this.property()   or
      this.colon()      or
      this.comma()      or
      this.percent()    or
      this.identifier() or
      this.number()     or
      this.string()     or
      this.color()      or
      this.important()  or
      this.value()      or
      this.semicolon()  or
      this.eos()

  defer: (tok) ->
    this.deferredTokens.push(tok)

  deferred: ->
    this.deferredTokens.length && this.deferredTokens.shift()

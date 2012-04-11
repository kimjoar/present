Lexer = module.exports = (str, options) ->
  options || (options = {})
  @input = str.replace(/\r\n|\r/g, '\n')
  @lineno = 1
  @deferredTokens = []
  @inBraces = false
  @inBrackets = false
  @stash = []
  this

Lexer.prototype =
  #
  # Construct a token with the given `type` and `val`.
  #
  token: (type, val) ->
    {
      type: type
      line: @lineno
      val: val
    }

  #
  # Consume the given `len` of input, i.e. we are finished with it.
  #
  consume: (len) ->
    @input = @input.substr(len)

  #
  # Scan for `type` with the given `regexp`.
  #
  scan: (regexp, type) ->
    if captures = regexp.exec(@input)
      # When we find a match, we consume it and create a token
      @consume(captures[0].length)
      @token(type, captures[1])

  #
  # end-of-source
  #
  eos: ->
    return if @input.length
    @token('eos')

  #
  # element selector
  #
  element: ->
    return if @inBraces or @inBrackets
    @scan(/^(\w+)/, 'element')

  #
  # universal selector
  #
  universal: ->
    return if @inBraces or @inBrackets
    @scan(/^\*/, 'universal')

  #
  # at-rules
  #
  atRule: ->
    @scan(/^@charset/,   "charset")  or
    @scan(/^@import/,    "import")   or
    @scan(/^@font-face/, "fontFace") or
    @scan(/^@media/,     "media")

  #
  # pseudo classes and elements
  #
  pseudo: ->
    @scan(/^(::?[\w-]+)/, 'pseudo')

  #
  # braces
  #
  braces: ->
    if captures = /^{/.exec(@input)
      @inBraces = true
      @consume(captures[0].length)
      @token('{', captures[1])
    else if captures = /^}/.exec(@input)
      @inBraces = false
      @consume(captures[0].length)
      @token('}', captures[1])

  #
  # brackets
  #
  bracket: ->
    if captures = /^\[/.exec(@input)
      @inBrackets = true
      @consume(captures[0].length)
      @token('[', captures[1])
    else if captures = /^\]/.exec(@input)
      @inBrackets = false
      @consume(captures[0].length)
      @token(']', captures[1])

  #
  # id selector
  #
  id: ->
    return if @inBraces
    @scan(/^#([\w-]+)/, 'id')

  #
  # class selector
  #
  className: ->
    return if @inBraces
    @scan(/^\.([\w-]+)/, 'class')

  #
  # property
  #
  property: ->
    if captures = /^([\w-]+):/.exec(@input)
      @consume(captures[0].length)
      @defer(@token(':'))
      @token('property', captures[1])

  equal: ->
    @scan(/^=/, "=")

  includes: ->
    @scan(/^~=/, "~=")

  dashmatch: ->
    @scan(/^\|=/, "|=")

  colon: ->
    @scan(/^:/, ":")

  semicolon: ->
    @scan(/^;/, ";")

  comma: ->
    @scan(/^,/, ",")

  percent: ->
    @scan(/^%/, "%")

  adjacentSibling: ->
    @scan(/^\+/, "+")

  generalSibling: ->
    @scan(/^~/, "~")

  child: ->
    @scan(/^>/, ">")

  identifier: ->
    @scan(/^([0-9a-zA-Z-]+)/, 'identifier')

  string: ->
    @scan(/^(\"[^\"]+\"|\'[^\']+\')/, 'string')

  number: ->
    @scan(/^(-?[0-9\.]+)/, 'number')

  color: ->
    colors =
      hex:  /^(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3})/
      rgb:  /^(rgb\([0-9]+%?, *[0-9]+%?, *[0-9]+%?\))/
      hsl:  /^(hsl\([0-9]+%?, *[0-9]+%?, *[0-9]+%?\))/
      rgba: /^(rgba\([0-9]+%?, *[0-9]+%?, *[0-9]+%?, *[0-9.]+\))/
      hsla: /^(rgba\([0-9]+%?, *[0-9]+%?, *[0-9]+%?, *[0-9.]+\))/

    for name, regex of colors
      if captures = regex.exec(@input)
        @consume(captures[0].length)
        return @token('color', captures[1])

  important: ->
    @scan(/^!important/, 'important');

  whitespace: ->
    @scan(/^([ ]+)/, 'whitespace')

  tab: ->
    @scan(/^(\t+)/, 'tab')

  comment: ->
    @scan(/^(\/\*(?:\s|\S)+?\*\/)/, 'comment')

  newline: ->
    if newline = @scan(/^\n/, 'newline')
      @lineno += 1
      newline

  url: ->
    @scan(/^url\((.+)\)/, 'url')

  unknown: ->
    @scan(/^([^ ,;!}]+)/, 'unknown')

  lookahead: (n) ->
    fetch = n - @stash.length;
    @stash.push(@next()) while fetch-- > 0
    @stash[n - 1]

  peek: ->
    @lookahead(1)

  stashed: ->
    @stash.length && @stash.shift()

  advance: ->
    @stashed() || @next()

  next: ->
    @deferred()     or
      @comment()    or
      @pseudo()     or
      @id()         or
      @atRule()     or
      @whitespace() or
      @tab()        or
      @newline()    or
      @braces()     or
      @bracket()    or
      @equal()      or
      @includes()   or
      @dashmatch()  or
      @adjacentSibling() or
      @generalSibling() or
      @child()      or
      @universal()  or
      @element()    or
      @className()  or
      @property()   or
      @colon()      or
      @comma()      or
      @percent()    or
      @color()      or
      @number()     or
      @url()        or
      @identifier() or
      @string()     or
      @important()  or
      @semicolon()  or
      @unknown()    or
      @eos()

  defer: (tok) ->
    @deferredTokens.push(tok)

  deferred: ->
    @deferredTokens.length && @deferredTokens.shift()

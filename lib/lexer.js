var Lexer = module.exports = function Lexer(str, options) {
  options || (options = {});
  this.input = str.replace(/\r\n|\r/g, '\n');
  this.lineno = 1;
  this.deferredTokens = [];
  this.inBraces = false;
}

Lexer.prototype = {
  /**
   * Construct a token with the given `type` and `val`.
   */
  tok: function(type, val) {
    return {
      type: type
    , line: this.lineno
    , val: val
    }
  },

  /**
   * Consume the given `len` of input, i.e. we are finished with it.
   */
  consume: function(len) {
    this.input = this.input.substr(len);
  },

  /**
   * Scan for `type` with the given `regexp`.
   */
  scan: function(regexp, type) {
    var captures;
    if (captures = regexp.exec(this.input)) {
      // When we find a match, we consume it and create a token
      this.consume(captures[0].length);
      return this.tok(type, captures[1]);
    }
  },

  /**
   * end-of-source
   */
  eos: function() {
    if (this.input.length) return;
    return this.tok('eos');
  },

  /**
   * tag selector
   */
  tag: function() {
    if (this.inBraces) return;
    return this.scan(/^(\w+)/, 'tag')
  },

  /**
   * pseudo-class
   */
  pseudo: function() {
    return this.scan(/:([\w-]+)/, 'pseudo');
  },

  /**
   * braces
   */
  braces: function() {
    var captures;
    if (captures = /^{/.exec(this.input)) {
      this.inBraces = true;
      this.consume(captures[0].length);
      return this.tok('startBraces', captures[1]);
    } else if (captures = /^}/.exec(this.input)) {
      this.inBraces = false;
      this.consume(captures[0].length);
      return this.tok('endBraces', captures[1]);
    }
  },

  /**
   * id selector
   */
  id: function() {
    if (this.inBraces) return;
    return this.scan(/^#([\w-]+)/, 'id');
  },

  /**
   * class selector
   */
  className: function() {
    if (this.inBraces) return;
    return this.scan(/^\.([\w-]+)/, 'class');
  },

  /**
   * property
   */
  property: function() {
    var captures;
    if (captures = /^([\w-]+):/.exec(this.input)) {
      this.consume(captures[0].length);
      this.defer(this.tok(':'));
      return this.tok('property', captures[1]);
    }
  },

  colon: function() {
    return this.scan(/^:/, ":");
  },

  semicolon: function() {
    return this.scan(/^;/, ";");
  },

  value: function() {
    return this.scan(/^([^;!}]+)/, 'value');
  },

  whitespace: function() {
    return this.scan(/^([ ]+)/, 'whitespace');
  },

  newline: function() {
    return this.scan(/^(\n)/, 'newline');
  },

  advance: function() {
    return this.next();
  },

  next: function() {
    return this.deferred()
      || this.id()
      || this.whitespace()
      || this.newline()
      || this.braces()
      || this.tag()
      || this.className()
      || this.property()
      || this.colon()
      || this.value()
      || this.semicolon()
      || this.eos()
  },

  defer: function(tok) {
    this.deferredTokens.push(tok);
  },

  deferred: function() {
    return this.deferredTokens.length && this.deferredTokens.shift();
  }
}

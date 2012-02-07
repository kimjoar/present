var Lexer = module.exports = function Lexer(str, options) {
  options || (options = {});
  this.input = str.replace(/\r\n|\r/g, '\n');
  this.lineno = 1;
  this.deferredTokens = [];
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
  // TODO :: Split psuedo into its own function
  tag: function() {
    return this.scan(/^(\w+)/, 'tag')
  },

  /**
   * pseudo-class
   */
  pseudo: function() {
    return this.scan(/:(\w+)/, 'pseudo');
  },

  /**
   * braces
   */
  braces: function() {
    return this.scan(/^{/, 'startBraces') || this.scan(/^}/, 'endBraces');
  },

  /**
   * id selector
   */
  id: function() {
    return this.scan(/^#([\w-]+)/, 'id');
  },

  /**
   * class selector
   */
  className: function() {
    return this.scan(/^\.([\w-]+)/, 'class');
  },

  defer: function(tok) {
    this.deferredTokens.push(tok);
  },

  deferred: function() {
    return this.deferredTokens.length && this.deferredTokens.shift();
  }
}

var Lexer = require('../lib/lexer');
var should = require('should');

describe("Lexer", function() {
  describe("eos", function() {
    it("returns eos token if at end-of-source", function() {
      var lexer = new Lexer("");
      lexer.eos().should.have.property('type', 'eos');
    });

    it("returns undefined if not at end-of-source", function() {
      var lexer = new Lexer("#test {}");
      should.not.exist(lexer.eos());
    });
  });

  describe("tag", function() {
    it("returns tag token if proper tag selector", function() {
      var lexer = new Lexer("a");
      lexer.tag().should.have.property('type', 'tag');
    });

    it("returns tag token if tag contains pseudo-class", function() {
      var lexer = new Lexer("a:hover");
      lexer.tag().should.have.property('type', 'tag');
      lexer.deferred().should.have.property('type', ':');
      lexer.deferred().should.have.property('type', 'pseudo');
    });

    it("returns correct value if proper tag selector", function() {
      var lexer = new Lexer("a");
      lexer.tag().should.have.property('val', 'a');
    });

    it("returns correct value if tag with pseudo-class", function() {
      var lexer = new Lexer("a:hover");
      lexer.tag().should.have.property('val', 'a');
      lexer.deferred();
      lexer.deferred().should.have.property('val', 'hover');
    });
  });

  describe("id", function() {
    it("returns id token if proper id selector", function() {
      var lexer = new Lexer("#test");
      lexer.id().should.have.property('type', 'id');
    });

    it("returns correct value if proper id selector", function() {
      var lexer = new Lexer("#test");
      lexer.id().should.have.property('val', 'test');
    });
  });

  describe("className", function() {
    it("returns class token if proper class selector", function() {
      var lexer = new Lexer(".test");
      lexer.className().should.have.property('type', 'class');
    });

    it("returns correct value if proper class selector", function() {
      var lexer = new Lexer(".test");
      lexer.className().should.have.property('val', 'test');
    });
  });
});

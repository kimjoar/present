var Lexer = require('../lib/lexer'),
    should = require('should');

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
      var lexer = new Lexer("h1");
      lexer.tag().should.have.property('type', 'tag');
    });

    it("returns correct value if proper tag selector", function() {
      var lexer = new Lexer("h1");
      lexer.tag().should.have.property('val', 'h1');
    });
  });

  describe("pseudo", function() {
    it("returns pseudo token if proper pseudo-class", function() {
      var lexer = new Lexer(":hover");
      lexer.pseudo().should.have.property('type', 'pseudo');
    });

    it("returns pseudo token if pseudo-class contains -", function() {
      var lexer = new Lexer(":first-line");
      var pseudo = lexer.pseudo();
      pseudo.should.have.property('type', 'pseudo');
      pseudo.should.have.property('val', 'first-line');
    });

    it("returns correct value if tag with pseudo-class", function() {
      var lexer = new Lexer(":hover");
      lexer.pseudo().should.have.property('val', 'hover');
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

    it("does not include ' ' in id", function() {
      var lexer = new Lexer("#test p");
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

  describe("braces", function() {
    it("returns start braces token if a start braces is present", function() {
      var lexer = new Lexer("{");
      lexer.braces().should.have.property('type', 'startBraces');
    });

    it("returns end braces token if an end braces is present", function() {
      var lexer = new Lexer("}");
      lexer.braces().should.have.property('type', 'endBraces');
    });
  });

  describe("property", function() {
    it("returns a property token if proper property", function() {
      var lexer = new Lexer("background-color:");
      lexer.property().should.have.property('type', 'property');
      lexer.deferred().should.have.property('type', ':');
    });

    it("returns correct value if proper property", function() {
      var lexer = new Lexer("background-color:");
      lexer.property().should.have.property('val', 'background-color');
    });
  });

  describe("colon", function() {
    it("returns colon token if single colon", function() {
      var lexer = new Lexer(":");
      lexer.colon().should.have.property('type', ':');
    });
  });

  describe("value", function() {
    it("handles single-word value", function() {
      var lexer = new Lexer("Times");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', 'Times');
    });

    it("handles comma-separated words", function() {
      var lexer = new Lexer("Times, serif");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', 'Times, serif');
    });

    it("handles \"", function() {
      var lexer = new Lexer('"New Century Schoolbook"');
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', '"New Century Schoolbook"');
    });

    it("handles ()", function() {
      var lexer = new Lexer("white url(candybar.gif)");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', 'white url(candybar.gif)');
    });

    it("handles %", function() {
      var lexer = new Lexer("200%");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', '200%');
    });

    it("handles #", function() {
      var lexer = new Lexer("#fff");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', '#fff');
    });

    it("does not include ;", function() {
      var lexer = new Lexer("200%;");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', '200%');
    });

    it("does not include !", function() {
      var lexer = new Lexer("200% !important");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', '200% ');
    });

    it("does not include }", function() {
      var lexer = new Lexer("200%}");
      var value = lexer.value();
      value.should.have.property('type', 'value');
      value.should.have.property('val', '200%');
    });
  });

  describe("semicolon", function() {
    it("returns semicolon token if single semicolon", function() {
      var lexer = new Lexer(";");
      lexer.semicolon().should.have.property('type', ';');
    });
  });

  describe("newline", function() {
    it("returns newline token if single newline", function() {
      var lexer = new Lexer("\n");
      lexer.newline().should.have.property('type', 'newline');
    });
  });

  describe("advance", function() {
    it('should find all tokens in "#test {}"', function() {
      var lexer = new Lexer("#test {}");
      lexer.advance().should.have.property('type', 'id');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'startBraces');
      lexer.advance().should.have.property('type', 'endBraces');
      lexer.advance().should.have.property('type', 'eos');
    });

    it('should find all tokens in "#test p .good {}"', function() {
      var lexer = new Lexer("#test p .good {}");
      lexer.advance().should.have.property('type', 'id');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'tag');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'class');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'startBraces');
      lexer.advance().should.have.property('type', 'endBraces');
      lexer.advance().should.have.property('type', 'eos');
    });

    it('should find all tokens in "#test {color: #fff;}"', function() {
      var lexer = new Lexer("#test {color: #fff;}");
      lexer.advance().should.have.property('type', 'id');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'startBraces');
      lexer.advance().should.have.property('type', 'property');
      lexer.advance().should.have.property('type', ':');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'value');
      lexer.advance().should.have.property('type', ';');
      lexer.advance().should.have.property('type', 'endBraces');
      lexer.advance().should.have.property('type', 'eos');
    });

    it('should find all tokens in "#test {color: #fff;\nfont: 12px;}"', function() {
      var lexer = new Lexer("#test {color: #fff;\nfont: 12px}");
      lexer.advance().should.have.property('type', 'id');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'startBraces');
      lexer.advance().should.have.property('type', 'property');
      lexer.advance().should.have.property('type', ':');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'value');
      lexer.advance().should.have.property('type', ';');
      lexer.advance().should.have.property('type', 'newline');
      lexer.advance().should.have.property('type', 'property');
      lexer.advance().should.have.property('type', ':');
      lexer.advance().should.have.property('type', 'whitespace');
      lexer.advance().should.have.property('type', 'value');
      lexer.advance().should.have.property('type', 'endBraces');
      lexer.advance().should.have.property('type', 'eos');
    });
  });
});

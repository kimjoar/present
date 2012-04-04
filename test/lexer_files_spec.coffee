Lexer = require('../')
should = require('should')
fs = require('fs')
path = require('path')
glob = require('glob')

advanceTokens = (string, tokens) ->
  lexer = new Lexer(string)
  lexer.advance().should.have.property('type', type) for type in tokens

tokens = (file) ->
  basename = path.basename(file, ".css")
  tokensFile = path.dirname(file) + "/" + basename +  ".txt"
  lines = fs.readFileSync(tokensFile).toString().split("\n")
  lines[0...-1]

ensureTokensIn = (file) ->
 css = fs.readFileSync(file).toString()
 advanceTokens css, tokens(file)

files = glob.sync "test/files/**/*.css"

describe "Lexer files", ->
  for file in files
    it "checks #{file}", ->
      ensureTokensIn file for file in files

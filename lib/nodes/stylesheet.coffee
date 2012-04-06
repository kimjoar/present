Node = require('./node')

class Stylesheet extends Node
  constructor: () ->
    this.rules = []

  push: (rule) ->
    this.rules.push(rule)

module.exports = Stylesheet

Node = require('./node')

class Stylesheet extends Node
  constructor: () ->
    this.nodes = []

  push: (node) ->
    this.nodes.push(node)

module.exports = Stylesheet

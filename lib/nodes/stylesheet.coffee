Node = require('./node')

class Stylesheet extends Node
  constructor: () ->
    @nodes = []

  push: (node) ->
    @nodes.push(node)

module.exports = Stylesheet

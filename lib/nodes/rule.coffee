Node = require('./node')

class Rule extends Node
  constructor: () ->
    @nodes = []

  push: (node) ->
    @nodes.push(node)

module.exports = Rule


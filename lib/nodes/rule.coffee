Node = require('./node')

class Rule extends Node
  constructor: () ->
    this.nodes = []

  push: (node) ->
    this.nodes.push(node)

module.exports = Rule


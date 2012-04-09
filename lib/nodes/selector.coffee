Node = require('./node')

class Selector extends Node
  constructor: () ->
    this.nodes = []

  push: (node) ->
    this.nodes.push(node)

module.exports = Selector

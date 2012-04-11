Node = require('./node')

class Selector extends Node
  constructor: () ->
    @nodes = []

  push: (node) ->
    @nodes.push(node)

module.exports = Selector

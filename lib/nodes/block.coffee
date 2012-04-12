Node = require('./node')

class Block extends Node
  constructor: () ->
    @nodes = []

  push: (node) ->
    @nodes.push(node)

module.exports = Block


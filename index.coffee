lib = if process.env.LEXER_COV then 'lib-cov' else 'lib'
module.exports = require('./' + lib + '/lexer')

lib = if process.env.PRESENT_COV then 'lib-cov' else 'lib'
module.exports = require('./' + lib)

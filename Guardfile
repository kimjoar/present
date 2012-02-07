guard "shell" do
  watch(%r{^test/(.+)_spec\.js$}) do |m|
    `node_modules/.bin/mocha -c --reporter dot test/#{m[1]}_spec.js`
  end

  watch(%r{^lib/(.+)\.js$}) do |m|
    `node_modules/.bin/mocha -c --reporter dot test/#{m[1]}_spec.js`
  end
end

guard "shell" do
  watch(%r{^test/(.+)_spec\.coffee$}) do |m|
    `node_modules/.bin/mocha -c --reporter dot test/#{m[1]}_spec.coffee`
  end

  watch(%r{^lib/(.+)\.coffee$}) do |m|
    `node_modules/.bin/mocha -c --reporter dot test/#{m[1]}_spec.coffee`
  end
end

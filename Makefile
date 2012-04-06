COFFEE = $(shell find lib -name "*.coffee")
JS = $(COFFEE:.coffee=.js)
REPORTER = dot

test:
	@./node_modules/.bin/mocha --reporter $(REPORTER)

test-cov: build
	@jscoverage lib lib-cov
	@PRESENT_COV=1 $(MAKE) test REPORTER=html-cov > test/coverage.html
	@rm -rf lib-cov
	@rm -f $(JS)

build: $(JS)

%.js: %.coffee
	@coffee -c $<

clean:
	@rm -f $(JS)
	@rm -f test/coverage.html

.PHONY: test build clean test-cov

COFFEE = $(shell find lib -name "*.coffee")
JS = $(COFFEE:.coffee=.js)

test:
	@./node_modules/.bin/mocha

build: $(JS)

%.js: %.coffee
	coffee -c $<

clean:
	rm -f $(JS)

.PHONY: test build clean

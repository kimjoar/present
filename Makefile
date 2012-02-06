test:
	@./node_modules/.bin/mocha

watch:
	@watch -q $(MAKE) lib/lexer.js

.PHONY: test

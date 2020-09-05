
build:
	npx truffle build

# eg: make deploy-yielder network=kovan
deploy-yielder: build
	npx truffle exec --network $(network) scripts/deploy-yielder.js

.PHONY: build deploy-yielder

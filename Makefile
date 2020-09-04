
build:
	npx truffle build

# eg: make deploy-liquidator network=kovan
deploy-liquidator: build
	npx truffle exec --network $(network) scripts/deploy-liquidator.js

.PHONY: build deploy-liquidator

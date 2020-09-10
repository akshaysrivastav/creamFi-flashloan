
CreamFi Helper
=================


This is a helper repository to CreamFi.

The smart contract contains the on-chain logic for flash loans and Cream token yields.
Please see the implementation at **_Yielder.sol_**. All other contracts are helper for flash loans - yield farming and are inherited by **_Yielder.sol_**.


Installation
------------
To run, pull the repository from Git and install its dependencies. You will need [npm](https://docs.npmjs.com/cli/install) installed.

    git clone https://github.com/akshaysrivastav/creamFi-flashloan
    cd creamFi-flashloan
    `npm ci`

```
If 'npm ci' throws any error then try 'npm install'
```

You can then compile the contracts with:

    npm run compile

Note: this project use truffle. The command above is the best way to compile contracts.


Testing
-------
Mocha contract tests are defined under the test directory. To run the tests run:

    npm run test

Assertions used in our tests are provided by [ChaiJS](http://chaijs.com).

Code Coverage
-------------
To run code coverage, run:

    npm run coverage

Linting
-------
To lint the code, run:

    npm run lint

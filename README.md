
bZx Liquidation
=================


This is a helper repository to liquidate unhealthy bZx loans.

It contains a nodejs script to monitor unhealthy loans and initiate liquidation transactions along with some helper utilities.

The smart contract contains the on-chain logic for flash loans and liquidations.
Please see the implementation at **_Liquidator.sol_**. All other contracts are helper for flash loans and are inherited by **_Liquidator.sol_**.


Installation
------------
To run, pull the repository from GitHub and install its dependencies. You will need [npm](https://docs.npmjs.com/cli/install) installed.

    git clone https://github.com/tomcbean/liquidation_helper
    cd liquidation_helper
    `npm install`

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

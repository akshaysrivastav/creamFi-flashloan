
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




# Documentation

Contract Name: Yielder.sol

## Points: 

- All functions are owner protected, only Owner can call.
- To interact with Yielder you need to enable it to use your funds. This can be done by going to the respective erc20 contract like DAI and calling its approve() function with parameters as:
    * Address of Yielder contract.
    * amount to approve in decimals.

To save gas this can be done only once for every token with large amounts.

- The Yielder contract supports both types of assets for yield farming, Erc20 tokens as well as Ether.
- All Funds that are sent to Yielder are fully recoverable including Ether and all Erc20 tokens.


## Contract Usage:
#### For Section A of the requirements doc

Txn 1 - Call supplyToCream() which takes parameters
* cTokenAddr - address of cToken contract.
* amount - amount of tokens to be supplied (in decimals).
* isCEther - true if supplying Ether else false.
 
Txn 2 - call start() 
* cTokenAddr -  address of cToken contract.
* flashLoanAmount - amount of tokens in decimals.
* isCEther - true if the asset is Ether else false.
* windYield - true.

#### For Section B Unwind CREAM farming

Txn 1 - call start() 
* cTokenAddr -  address of cToken contract.
* flashLoanAmount - amount of tokens in decimals.
* isCEther - true if the asset is Ether else false.
* windYield - false.

Txn 2 - call withdrawFromCream()
* cTokenAddr - address of cToken contract.
* amount - amount of tokens to be withdrawn (in decimals).

#### For Section C - Claim CREAM

This can be done by three ways - call claim for all markets, call claim for single market, perform any transaction on respective market. The first two are described below.

Call claimAndTransferCream() with parameters
* comptrollerAddr - Address of Unitroller contract.
* receiver -  Address of CREAM receiver.

Call claimAndTransferCreamForCToken() with parameters
* comptrollerAddr - Address of Unitroller contract.
* cTokens - array of cToken addresses for which you want to receive Cream, like [“0xabc...”, “0xdef...”]
* receiver -  Address of CREAM receiver

#### Section D - To transfer funds lying in the Yielder smart contract

For ETH - call transferEth()
* to - address of receiver
* amount - amount in decimals (wei)

For any ERC20 - call transferToken()
* token - address of erc20 token to transfer
* to - address of receiver
* amount - amount in decimals

#### Section E - Supply and Borrow balance of contract

Call supplyBalance()
* cToken - address of cToken
* Call borrowBalance()
* cToken - address of cToken


## Additional Functions:

Transfer Ownership of Yielder.sol

Call transferOwnership()
* newOwner - address of new Owner

borrowFromCream() - This function borrows any supported token from Cream protocol. This does not involve any flash loan. 

repayBorrowedFromCream - This function repays borrowed amounts of  any supported token on Cream protocol. This does not involve any flash loan. 

ethBalance() - shows the Ether balance of Yielder.

tokenBalance() - shows erc20 token balance of Yielder


## Contract Deployment
Clone the repo

Install dependencies (See Above).

In the project's folder, create  .env file (dotenv). Copy this into that file with appropriate values (See .env.example file).
* MAINNET_GAS_PRICE=100000000000    # 100 gWei
* PRIVATEKEY="private-key-excluding-0x"
* INFURA_ID="infura-project-id"

To deploy the contract run this command in project’s directory
```
make deploy-yielder network=mainnet
Or
make deploy-yielder network=ropsten
```
 

Documentation is here also - https://docs.google.com/document/d/1wKlKHz5S2rJZPOuJpcocI8bMAPjZCcwpdrvSA-iFY7A/edit?usp=sharing

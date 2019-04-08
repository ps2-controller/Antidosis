# Antidosis CLI Demo

## Getting Started
Clone this repo. 

`cd Antidosis`

`npm install`

To run this demo, you will need [Truffle and Ganache](https://truffleframework.com/docs).

Ensure that Ganache is running at port 8545 (or change the port in `ethersConfig.js`).

run `touch .env` and `open .env`.
Update the .env file's contents per `dotenvExample.txt`.

Clone this repo and run `npm run cli-demo`. If migrations are not up to date, truffle will compile and deploy your contracts to your local development blockchain. 

Run `cd src`, `cd data`, and `open deployedContractAddresses.js`. Update the addresses in this file to the addresses from your truffle migration. *Note, I'm working on automating this process - bear with me!*

This deploys the core Antidosis contract, a dummy ERC-721 contract, and an ERC-20 contract we will call `Dai` (no dollar peg since it's testnet) which is a `payment token` in which taxes, purchases, etc are denominated.

You are now in the Antidosis CLI daemon and have access to the Antidosis commands. For a full description of each Antidosis command and how to use it, [click here](https://github.com/ps2-controller/Antidosis/blob/master/documents/cli-demo-commands.md). Otherwise, you can follow the guided demo flow of commands.

## Guided CLI demo
*Note that currently, when each command is run in the demo, you will need to run `npm run cli-demo` again to restart the daemon. Hoping to fix this soon.*

First, type `mintAndLock`. This creates a new ERC-721 token on our dummy ERC-721 contract, and sends the newly created token to our Antidosis core contract. The ERC-721 token is now locked, and a corresponding ERC-20 contract, the `Asset Tokenization Contract` is now deployed with some default values for Harberger tax rate, Harberger tax recipient, ERC 20 name, supply etc. These values are configurable, and they will soon be configurable through the CLI; for now, default values can be modified in `./src/mintAndLock.js`. 

Save the AssetTokenizationContract address.

Now, you will need Dai to pay the Harberger taxes on any shares you acquire. We have a sample ERC 20 contract we will call Dai (though there is no dollar peg). 

Reopen the daemon with `npm run cli-demo`.

Run `getDai`: you will be prompted for your address and the amount of Dai you would like to take. A blank entry for the address will use your default accessing address. Take as much Dai from the dummy contract as you want - 10000000 may be a good amount. 

Reopen the daemon with `npm run cli-demo`.

You will also need to set your Harberger valuation and a specified duration (the longer the duration, the more funds will be escrowed for taxation. If your tokens are bought before the escrow runs out, you are reimbursed the unaccrued taxes from your escrowed funds.) To do this, run `setHarberger` and populate the `Asset Tokenization Contract` address, a valuation (per token/in Dai), and a duration - you can set 10 and 10000 if you're unsure what to put. 

Reopen the daemon with `npm run cli-demo`.

You will also need to call the `allow` function on the Dai contract to allow tax payments to the `Asset Tokenization Contract`. You can do this by running `allowDai`. If you leave the "amount" inquiry blank, you will give allowance for your total Dai supply - this is recommended. 

Reopen the daemon with `npm run cli-demo`.

Now that you've got a valuation, you're ready to take some shares of the deployed contract. Shares currently start at a price of 0 (this may be configurable in the future) you can take tokens from the `Asset Tokenization Contract`. Run `takeTokens` and take some tokens - maybe 3000. This will escrow enough Dai from your wallet to pay taxes on these 3000 tokens fur your set duration, and it will send you 3000 tokens. If you do not renew your escrow, the tokens will drop to a 0 valuation and be freely claimable by the highest bidder. 

Reopen the daemon with `npm run cli-demo`.

Before you perform a nonconsensual purchase of the tokens from a second address, you will need to set a valuation for that second address. You can do this from your second wallet in Ganache (configured in your `.env` file) by running `setHarberger2`.

Reopen the daemon with `npm run cli-demo`.

If you'd like to call the transfer function from the second wallet, you will need Dai in it to lock the escrow - you can run `getDai2` in the daemon. You can set an allowance with `allowDai2`.

Now, from EITHER address (`msg.sender` will pay the escrow) you may call `transferTokens` - you will be prompted for the `Asset Tokenization Contract` address and then asked to select one of your configured wallets to send the transaction. As long as the `msg.sender` has enough Dai to pay the escrow + valuation of current holder, and the recipient has an appropriate Harberger valuation set (this can be determined with `getHarberger`), anybody can transfer the tokens from the current token holder to a new owner. 

Antidosis also has a configurable framework for arbitrary functionality from the `Asset Tokenization Contract`. This adds reasonable scope for developer creativity -  a future version of this demo will showcase shareholders of the underlying asset operating as a DAO to drive decisions around the underlying asset. 

Thanks for checking out the demo! 


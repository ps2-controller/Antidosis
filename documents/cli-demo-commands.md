TODO - command descriptions

`mintAndLock` - This creates a new ERC-721 token on our dummy ERC-721 contract, and sends the newly created token to our Antidosis core contract. The ERC-721 token is now locked, and a corresponding ERC-20 contract, the `Asset Tokenization Contract` is now deployed with some default values for Harberger tax rate, Harberger tax recipient, ERC 20 name, supply etc. These values are configurable, and they will soon be configurable through the CLI; for now, default values can be modified in `./src/mintAndLock.js`. 

`getDai` - Mints testnet Dai to the calling address.

`getDai2` - Calls `getDai` with the second wallet configured in the `dotenv` file.

`allowDai` - Sets an allowance for the Asset Tokenization Contract to escrow Dai payments from the calling address.

`allowDai2` - Calls `allowDai` with the second wallet configured in the `dotenv` file.

`setHarberger` - Sets Harberger valuation and duration for the calling address.

`setHarberger2` - Calls `setHarberger` with the second wallet configured in the `dotenv` file.

`getHarberger` - Returns Harberger valuation and duration for a passed address

`takeTokens` - Takes unclaimed minted tokens from the Asset Tokenization Contract, withdraws and begins applying Dai escrow. 

`takeTokens2` - Calls `takeTokens` with the second wallet configured in the `dotenv` file.

`transferTokens` - Enables nonconsensual purchase of Harberger-taxed shares from a current owner; resolves their escrowed funds; draws escrow for new owner. 
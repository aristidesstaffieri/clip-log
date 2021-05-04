# Clip Log

## Intro

Clip Log is an example contract for the (Flow)[https://www.onflow.org/] ecosystem.

This is inspired/derived from the KittyItems/TopShot contracts found here -
(KittyItems)[https://github.com/onflow/kitty-items]
(TopShot)[https://github.com/dapperlabs/nba-smart-contracts]

## Contract Overview

Clip NFTs represent a skate trick, at a skate spot, on a specific date.
`contracts/Clips.cdc`

Copper FTs represent tokens for Clip Log transactions
`contracts/Copper.cdc`

ClipsMarket represents the contract for selling/buying and other Clip transactions
`contracts/ClipsMarket.cdc`


## Deployment

Follow testnet/emulator instructions detailed in -
https://github.com/onflow/kitty-items/blob/master/README.md

## Emulator
You can setup the emulator to try this locally using the Flow-CLI as detailed in - 
https://github.com/onflow/kitty-items

Once you're running the emulator and have deployed the contracts, you can run scripts to affect state in the emulator, like this -

`flow transactions send  ./transactions/clips/setup_account.cdc --signer emulator-account`
`flow transactions send  ./transactions/clips/mint_clips.cdc --signer emulator-account --arg Address:"0xf8d6e0586b0a20c7" --arg UInt64:"123" --arg UInt64:"123" --arg UInt64:"123"`

Running those two transactions should result in an admin account setup and a trick minted with the args as data.
Then you can run this to mint 10 tokens -

`flow transactions send  ./transactions/copper/setup_account.cdc --signer emulator-account`
`flow transactions send  ./transactions/copper/mint_tokens.cdc --signer emulator-account --arg Address:"0xf8d6e0586b0a20c7" --arg UFix64:"10.00"`

At this point you should be able to run 

`transactions/clips/scripts/get_clips_for_account.cdc`

and see the ID for the Clip previously created. You can run scripts like this using the (GO SDK)[https://docs.onflow.org/flow-go-sdk]


## TODO

Write tests and Go SDK.
Optional web interface and server for off chain data sources/interactions.
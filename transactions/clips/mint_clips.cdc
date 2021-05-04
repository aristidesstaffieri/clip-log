import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Clips from "../../contracts/Clips.cdc"

// This transaction uses the NFTMinter resource to mint a new NFT.
//
// It must be run with the account that has the minter resource
// stored at path /storage/NFTMinter.

transaction(recipient: Address, skaterId: UInt64, trickId: UInt64, filmerId: UInt64) {
    
    // local variable for storing the minter reference
    let minter: &Clips.NFTMinter

    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Clips.NFTMinter>(from: Clips.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(Clips.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(recipient: receiver, skaterId: skaterId, trickId: trickId, filmerId: filmerId)
    }
}
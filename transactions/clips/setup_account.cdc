import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Clips from "../../contracts/Clips.cdc"

// This transaction configures an account to hold Clips.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&Clips.Collection>(from: Clips.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Clips.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: Clips.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Clips.Collection{NonFungibleToken.CollectionPublic, Clips.ClipsCollectionPublic}>(Clips.CollectionPublicPath, target: Clips.CollectionStoragePath)
        }
    }
}
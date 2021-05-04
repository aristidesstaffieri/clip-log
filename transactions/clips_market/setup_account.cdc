import ClipsMarket from "../../contracts/ClipsMarket.cdc"

// This transaction configures an account to hold SaleOffer items.

transaction {
    prepare(signer: AuthAccount) {

        // if the account doesn't already have a collection
        if signer.borrow<&ClipsMarket.Collection>(from: ClipsMarket.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- ClipsMarket.createEmptyCollection() as! @ClipsMarket.Collection
            
            // save it to the account
            signer.save(<-collection, to: ClipsMarket.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&ClipsMarket.Collection{ClipsMarket.CollectionPublic}>(ClipsMarket.CollectionPublicPath, target: ClipsMarket.CollectionStoragePath)
        }
    }
}
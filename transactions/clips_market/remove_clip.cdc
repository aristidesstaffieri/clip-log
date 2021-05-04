import ClipsMarket from "../../contracts/ClipsMarket.cdc"

transaction(itemID: UInt64) {
    let marketCollection: &ClipsMarket.Collection

    prepare(signer: AuthAccount) {
        self.marketCollection = signer.borrow<&ClipsMarket.Collection>(from: ClipsMarket.CollectionStoragePath)
            ?? panic("Missing or mis-typed ClipsMarket Collection")
    }

    execute {
        let offer <-self.marketCollection.remove(itemID: itemID)
        destroy offer
    }
}
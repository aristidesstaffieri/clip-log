import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Copper from "../../contracts/Copper.cdc"
import Clips from "../../contracts/Clips.cdc"
import ClipsMarket from "../../contracts/ClipsMarket.cdc"

transaction(itemID: UInt64, price: UFix64) {
    let CopperVault: Capability<&Copper.Vault{FungibleToken.Receiver}>
    let ClipsCollection: Capability<&Clips.Collection{NonFungibleToken.Provider, Clips.ClipsCollectionPublic}>
    let marketCollection: &ClipsMarket.Collection

    prepare(signer: AuthAccount) {
        // we need a provider capability, but one is not provided by default so we create one.
        let ClipsCollectionProviderPrivatePath = /private/ClipsCollectionProvider

        self.CopperVault = signer.getCapability<&Copper.Vault{FungibleToken.Receiver}>(Copper.ReceiverPublicPath)!
        assert(self.CopperVault.borrow() != nil, message: "Missing or mis-typed Copper receiver")

        if !signer.getCapability<&Clips.Collection{NonFungibleToken.Provider, Clips.ClipsCollectionPublic}>(ClipsCollectionProviderPrivatePath)!.check() {
            signer.link<&Clips.Collection{NonFungibleToken.Provider, Clips.ClipsCollectionPublic}>(ClipsCollectionProviderPrivatePath, target: Clips.CollectionStoragePath)
        }

        self.ClipsCollection = signer.getCapability<&Clips.Collection{NonFungibleToken.Provider, Clips.ClipsCollectionPublic}>(ClipsCollectionProviderPrivatePath)!
        assert(self.ClipsCollection.borrow() != nil, message: "Missing or mis-typed ClipsCollection provider")

        self.marketCollection = signer.borrow<&ClipsMarket.Collection>(from: ClipsMarket.CollectionStoragePath)
            ?? panic("Missing or mis-typed ClipsMarket Collection")
    }

    execute {
        let offer <- ClipsMarket.createSaleOffer (
            sellerItemProvider: self.ClipsCollection,
            itemID: itemID,
            skaterId: self.ClipsCollection.borrow()!.borrowClip(id: itemID)!.skaterId,
            trickId: self.ClipsCollection.borrow()!.borrowClip(id: itemID)!.trickId,
            filmerId: self.ClipsCollection.borrow()!.borrowClip(id: itemID)!.filmerId,
            sellerPaymentReceiver: self.CopperVault,
            price: price
        )
        self.marketCollection.insert(offer: <-offer)
    }
}
import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Copper from "../../contracts/Copper.cdc"
import Clips from "../../contracts/Clips.cdc"
import ClipsMarket from "../../contracts/ClipsMarket.cdc"

transaction(itemID: UInt64, marketCollectionAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let ClipsCollection: &Clips.Collection{NonFungibleToken.Receiver}
    let marketCollection: &ClipsMarket.Collection{ClipsMarket.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.marketCollection = getAccount(marketCollectionAddress)
            .getCapability<&ClipsMarket.Collection{ClipsMarket.CollectionPublic}>(
                ClipsMarket.CollectionPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow market collection from market address")

        let saleItem = self.marketCollection.borrowSaleItem(itemID: itemID)
                    ?? panic("No item with that ID")
        let price = saleItem.price

        let mainCopperVault = signer.borrow<&Copper.Vault>(from: Copper.VaultStoragePath)
            ?? panic("Cannot borrow Copper vault from acct storage")
        self.paymentVault <- mainCopperVault.withdraw(amount: price)

        self.ClipsCollection = signer.borrow<&Clips.Collection{NonFungibleToken.Receiver}>(
            from: Clips.CollectionStoragePath
        ) ?? panic("Cannot borrow Clips collection receiver from acct")
    }

    execute {
        self.marketCollection.purchase(
            itemID: itemID,
            buyerCollection: self.ClipsCollection,
            buyerPayment: <- self.paymentVault
        )
    }
}
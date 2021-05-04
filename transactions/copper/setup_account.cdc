import FungibleToken from "../../contracts/FungibleToken.cdc"
import Copper from "../../contracts/Copper.cdc"

// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the Copper

transaction {

    prepare(signer: AuthAccount) {

        if signer.borrow<&Copper.Vault>(from: Copper.VaultStoragePath) == nil {
            // Create a new Copper Vault and put it in storage
            signer.save(<-Copper.createEmptyVault(), to: Copper.VaultStoragePath)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&Copper.Vault{FungibleToken.Receiver}>(
                Copper.ReceiverPublicPath,
                target: Copper.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&Copper.Vault{FungibleToken.Balance}>(
                Copper.BalancePublicPath,
                target: Copper.VaultStoragePath
            )
        }
    }
}
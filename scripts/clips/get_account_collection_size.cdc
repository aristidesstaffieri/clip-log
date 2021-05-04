import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Clips from "../../contracts/Clips.cdc"

// This script returns the size of an account's Clips collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(Clips.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}
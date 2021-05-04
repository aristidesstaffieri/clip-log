
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Clips from "../../contracts/Clips.cdc"

pub fun main(owner: Address): [Int] {

    let acct = getAccount(owner)

    let collectionRef = acct.getCapability(/public/topshotSaleCollection)
        .borrow<&{Market.SalePublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
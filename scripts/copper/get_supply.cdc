import Copper from "../../contracts/Copper.cdc"

// This script returns the total amount of Copper currently in existence.

pub fun main(): UFix64 {

    let supply = Copper.totalSupply

    log(supply)

    return supply
}
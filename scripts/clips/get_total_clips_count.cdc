import Clips from "../../contracts/Clips.cdc"

// This scripts returns the number of Clips currently in existence.

pub fun main(): UInt64 {    
    return Clips.totalSupply
}
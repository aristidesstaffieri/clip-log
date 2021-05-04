import NonFungibleToken from "./NonFungibleToken.cdc"

// Clips
// A contract for the world's Skate Clips
//
pub contract Clips: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, skaterId: UInt64, trickId: UInt64, filmerId: UInt64)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // totalSupply
    //
    pub var totalSupply: UInt64

    pub struct ClipData {
        pub let skaterId: UInt64
        pub let trickId: UInt64
        pub let filmerId: UInt64

        init(skaterId: UInt64, trickId: UInt64, filmerId: UInt64) {
            self.skaterId = skaterId
            self.trickId = trickId
            self.filmerId = filmerId
        }
    }

    // Clip NFT
    //
    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID
        pub let id: UInt64

        // tricks metadata
        pub let data: ClipData

        // initializer
        //
        init(id: UInt64, skaterId: UInt64, trickId: UInt64, filmerId: UInt64) {
            self.id = id
            self.data = ClipData(skaterId: skaterId, trickId: trickId, filmerId: filmerId)
        }
    }

    // For storing Clips
    pub resource interface ClipsCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowClip(id: UInt64): &Clips.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Clip reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of Clip NFTs owned by an account
    //
    pub resource Collection: ClipsCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Clips.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowClip
        // Gets a reference to an NFT in the collection as a Clip
        // This is safe as there are no functions that can be called on the Clip.
        //
        pub fun borrowClip(id: UInt64): &Clips.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Clips.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, skaterId: UInt64, trickId: UInt64, filmerId: UInt64) {
            emit Minted(id: Clips.totalSupply, skaterId: skaterId, trickId: trickId, filmerId: filmerId)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create Clips.NFT(id: Clips.totalSupply, skaterId: skaterId, trickId: trickId, filmerId: filmerId))

            Clips.totalSupply = Clips.totalSupply + (1 as UInt64)
		}
	}

    // fetch
    // Get a reference to a Clip from an account's Collection, if available.
    // If an account does not have a Clips.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &Clips.NFT? {
        let collection = getAccount(from)
            .getCapability(Clips.CollectionPublicPath)!
            .borrow<&Clips.Collection{Clips.ClipsCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust Clips.Collection.borrowClip to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowClip(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        self.CollectionStoragePath = /storage/clipsCollection
        self.CollectionPublicPath = /public/clipsCollection
        self.MinterStoragePath = /storage/clipsMinter

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}
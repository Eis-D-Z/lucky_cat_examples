module bcs_secure::level_up {

    //imports
    use sui::bcs;
    use sui::object::{Self, UID};
    use sui::ecdsa_k1;
    use sui::tx_context::TxContext;
    use sui::transfer;

    use std::vector;


    //constants
    /// this is the public key that we will check against
    const PubKey: vector<u8> = x"03413b82d1c71e134d053bfd8db63a7eab006fec5eb038451be1eb11a99dc2c0d4";
    const EKeysDontMatch: u64 = 0;
    const EMessageMismatch: u64 = 1;


    /// an object that can level up
    struct LevelsUp has key, store {
        id: UID,
        level: u64
    }


    // functions

    /// mints a new level 1 nft, here everyone can mint an NFT
    public entry fun mint(recipient: address, ctx: &mut TxContext) {
        let newNFT = LevelsUp {
            id: object::new(ctx),
            level: 1
        };

        transfer::public_transfer(newNFT, recipient);

    }

    /// Levels up the NFT to the desired level.
    /// This requires a signed message that is the BCS representation of the NFT id and level.
    /// The private key that signs should match the PUBKEY public key
    public entry fun level_up(nft: &mut LevelsUp, level: u64, signature: vector<u8>, message: vector<u8>, hash: u8) {
        let key = ecdsa_k1::secp256k1_ecrecover(&signature, &message, hash);
        assert!(key == PubKey, EKeysDontMatch);

        let lvlBCS = bcs::to_bytes<u64>(&level);

        let i: u64 = 0;
        let max: u64 = vector::length<u8>(&lvlBCS);

        while (i < max) {
            let left: u8 = vector::pop_back(&mut lvlBCS);
            let right: u8 = vector::pop_back(&mut message);
            assert!(left == right, EMessageMismatch);
            i = i + 1;
        };

        let nft_address = object::uid_to_address(&nft.id);
        let owner_address_bcs = bcs::to_bytes<address>(&nft_address);
        assert!(owner_address_bcs == message, EMessageMismatch);

        nft.level = level;
    }

    // accessors
    public entry fun level(self: &LevelsUp): u64 {
        self.level
    }
}

#[test_only]
module bcs_secure::tests {
     use sui::test_scenario as ts;

     use bcs_secure::level_up::{Self as lvlup, LevelsUp};

     #[test]
     fun test_sig() {
        let user = @0x3301;
        let test = ts::begin(user);
        lvlup::mint(user, ts::ctx(&mut test));

        ts::next_tx(&mut test, user);

        let msg: vector<u8> = vector[
            3,  68,  1, 144,  91, 235, 223, 140,   4, 243,
            205,  95,  4, 244,  66, 163, 147, 114, 200, 220,
            50,  28, 41, 237, 251,  79, 156, 179,  11,  35,
            171, 150, 10,   0,   0,   0,   0,   0,   0,   0
        ];
        let signature: vector<u8> = vector[
            108,159,156,171,131,175,188,25,54,52,174,141,20,236,26,172,90,54,164,
            246,52,89,176,192,110,49,131,82,76,139,45,10,46,204,155,126,96,198,228,
            61,123,208,28,169,139,66,34,5,1,154,53,183,216,52,20,7,37,255,77,246,
            174,221,120,8,0
        ];

        let hash: u8 = 1;

        let nft = ts::take_from_sender<LevelsUp>(&test);

        lvlup::level_up(&mut nft, 10, signature, msg, hash);

        // ts::next_transaction(&test, user);
        assert!(10u64 == lvlup::level(&nft), 0);
        ts::return_to_sender<LevelsUp>(&test, nft);

        ts::end(test);
     }
}
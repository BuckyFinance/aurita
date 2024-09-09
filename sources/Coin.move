module account::coin {
    use std::signer;
    use std::string;
    use aptos_framework::aptos_account;
    use aptos_framework::coin::{Coin, Self, MintCapability, BurnCapability};

    struct USDC {}

    struct USDT {}

    struct WBTC {}

    struct STAPT {}

    struct CoinCapabiltity<phantom CoinType> has key {
        mint_capability: MintCapability<CoinType>,
        burn_capability: BurnCapability<CoinType>,
    }
    
    public fun initialize(owner: &signer) {
        let (burn_a, freeze_a, mint_a) = coin::initialize<USDC>(owner, string::utf8(b"USD Coin"), string::utf8(b"USDC"), 6, true);
        move_to(owner, CoinCapabiltity<USDC>{
            mint_capability: mint_a,
            burn_capability: burn_a,
        });
        coin::destroy_freeze_cap<USDC>(freeze_a);

        let (burn_b, freeze_b, mint_b) = coin::initialize<USDT>(owner, string::utf8(b"USD Tether"), string::utf8(b"USDT"), 6, true);
        move_to(owner, CoinCapabiltity<USDT>{
            mint_capability: mint_b,
            burn_capability: burn_b,
        });
        coin::destroy_freeze_cap<USDT>(freeze_b);

        let (burn_c, freeze_c, mint_c) = coin::initialize<WBTC>(owner, string::utf8(b"Wrapped Bitcoin"), string::utf8(b"WBTC"), 6, true);
        move_to(owner, CoinCapabiltity<WBTC>{
            mint_capability: mint_c,
            burn_capability: burn_c,
        });
        coin::destroy_freeze_cap<WBTC>(freeze_c);

        let (burn_d, freeze_d, mint_d) = coin::initialize<STAPT>(owner, string::utf8(b"Staked APT"), string::utf8(b"stAPT"), 6, true);
        move_to(owner, CoinCapabiltity<STAPT>{
            mint_capability: mint_d,
            burn_capability: burn_d,
        });
        coin::destroy_freeze_cap<STAPT>(freeze_d);
    }

}
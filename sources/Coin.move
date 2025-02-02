// module account::aurita_coin {
//     use std::debug::print;
//     use std::signer;
//     use std::string;
//     use aptos_framework::account;
//     use aptos_framework::coin::{Coin, Self, MintCapability, BurnCapability};

//     friend account::utils;

//     struct USDC has store {}

//     struct USDT has store {}

//     struct WBTC has store {}

//     struct STAPT has store {}
    
//     struct APT has store {}

//     struct WETH has store {}
    
//     struct CAKE has store {}

//     struct CoinCapabiltity<phantom CoinType> has key {
//         mint_capability: MintCapability<CoinType>,
//         burn_capability: BurnCapability<CoinType>
//     }

//     fun init_module(owner: &signer) {
//         let (burn_a, freeze_a, mint_a) =
//             coin::initialize<USDC>(
//                 owner,
//                 string::utf8(b"USD Coin"),
//                 string::utf8(b"USDC"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<USDC> { mint_capability: mint_a, burn_capability: burn_a }
//         );
//         coin::destroy_freeze_cap<USDC>(freeze_a);

//         let (burn_b, freeze_b, mint_b) =
//             coin::initialize<USDT>(
//                 owner,
//                 string::utf8(b"USD Tether"),
//                 string::utf8(b"USDT"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<USDT> { mint_capability: mint_b, burn_capability: burn_b }
//         );
//         coin::destroy_freeze_cap<USDT>(freeze_b);

//         let (burn_c, freeze_c, mint_c) =
//             coin::initialize<WBTC>(
//                 owner,
//                 string::utf8(b"Wrapped Bitcoin"),
//                 string::utf8(b"WBTC"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<WBTC> { mint_capability: mint_c, burn_capability: burn_c }
//         );
//         coin::destroy_freeze_cap<WBTC>(freeze_c);

//         let (burn_d, freeze_d, mint_d) =
//             coin::initialize<STAPT>(
//                 owner,
//                 string::utf8(b"Staked APT"),
//                 string::utf8(b"stAPT"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<STAPT> { mint_capability: mint_d, burn_capability: burn_d }
//         );
//         coin::destroy_freeze_cap<STAPT>(freeze_d);

//         let (burn_d, freeze_d, mint_d) =
//             coin::initialize<APT>(
//                 owner,
//                 string::utf8(b"Aptos Token"),
//                 string::utf8(b"APT"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<APT> { mint_capability: mint_d, burn_capability: burn_d }
//         );
//         coin::destroy_freeze_cap<APT>(freeze_d);

//         let (burn_d, freeze_d, mint_d) =
//             coin::initialize<WETH>(
//                 owner,
//                 string::utf8(b"Wrapped Ethereum"),
//                 string::utf8(b"wETH"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<WETH> { mint_capability: mint_d, burn_capability: burn_d }
//         );
//         coin::destroy_freeze_cap<WETH>(freeze_d);

//         let (burn_d, freeze_d, mint_d) =
//             coin::initialize<CAKE>(
//                 owner,
//                 string::utf8(b"CAKE"),
//                 string::utf8(b"CAKE"),
//                 6,
//                 true
//             );
//         move_to(
//             owner,
//             CoinCapabiltity<CAKE> { mint_capability: mint_d, burn_capability: burn_d }
//         );
//         coin::destroy_freeze_cap<CAKE>(freeze_d);
//     }


//     public entry fun mint<CoinType>(user: &signer, amount: u64) acquires CoinCapabiltity {
//         register<CoinType>(user);
//         let mint_capability =
//             &borrow_global<CoinCapabiltity<CoinType>>(@account).mint_capability;
//         let mint_coin = coin::mint(amount, mint_capability);
//         coin::deposit(signer::address_of(user), mint_coin);
//     }

//     public entry fun register<CoinType>(sender: &signer) {
//         if(coin::is_account_registered<CoinType>(signer::address_of(sender)) == false) {
//             coin::register<CoinType>(sender);
//         };
//     }

//     #[test_only]
//     public fun init_module_for_tests(sender: &signer) {
//         init_module(sender);
//     }

//     #[test_only]
//     public fun init<CoinType>(user: &signer) {
//         account::create_account_for_test(signer::address_of(user));
//         coin::register<CoinType>(user);
//     }

//     // #[test(owner = @account)]
//     // public fun testMintCoin(owner: &signer) acquires CoinCapabiltity {
//     //     init_module(owner);
//     //     // init<USDC>(owner);
//     //     mint<USDC>(owner, 100);
//     //     // print(&coin::balance<USDC>(@account));
//     // }

//     // #[test(owner = @account, user = @0x1001)]
//     // public fun testTransferCoin(owner: &signer, user: &signer) acquires CoinCapabiltity {
//     //     initialize(owner);
//     //     // init<USDC>(owner);
//     //     // init<USDC>(user);

//     //     mint<USDC>(@account, 100);

//     //     let amount: u64 = 30;
//     //     coin::transfer<USDC>(owner, signer::address_of(user), amount);
//     //     // print(&coin::balance<USDC>(signer::address_of(user)));
//     //     // print(&coin::balance<USDC>(signer::address_of(owner)));
//     // }
// }

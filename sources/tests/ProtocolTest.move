module account::protocol_test {
    use std::signer;
    use account::entry_positions_manager;
    use account::exit_positions_manager;
    use account::mock_aries;
    use account::storage;
    use account::user_lens;
    use account::coin::{Self, USDC, USDT, WBTC, STAPT, APT, WETH, CAKE};
    use aptos_framework::timestamp;
    use std::debug::print;
    use account::utils;
    use std::string;

    const INITIAL_COIN: u64 = 10000000000000; // 10^7
    const INITIAL_COIN_MOCK_POOL: u256 = 1000000000000; // 10^6
    const ARIES_MARKET: u64 = 0;

    #[test_only]
    public fun init_and_mint_coin(sender: &signer) {
        let sender_addr = signer::address_of(sender);

        coin::init<USDT>(sender);
        coin::init<USDC>(sender);
        coin::init<WBTC>(sender);
        coin::init<STAPT>(sender);
        coin::init<APT>(sender);
        coin::init<WETH>(sender);
        coin::init<CAKE>(sender);

        coin::mint<USDT>(sender_addr, INITIAL_COIN);
        coin::mint<USDC>(sender_addr, INITIAL_COIN);
        coin::mint<WBTC>(sender_addr, INITIAL_COIN);
        coin::mint<STAPT>(sender_addr, INITIAL_COIN);
        coin::mint<APT>(sender_addr, INITIAL_COIN);
        coin::mint<WETH>(sender_addr, INITIAL_COIN);
        coin::mint<CAKE>(sender_addr, INITIAL_COIN);
    }

    #[test_only]
    public fun set_up_test_for_time(aptos_framework: &signer) {
        // set up global time for testing purpose
        timestamp::set_time_has_started_for_testing(aptos_framework);
    }

    #[test_only(admin = @account, user1 = @0x1001)]
    public fun test_init(
        admin: &signer, user1: &signer, aptos_framework: &signer
    ) {

        // set up timestamp
        set_up_test_for_time(aptos_framework);

        // mint coin for admin and user
        coin::initialize(admin);
        init_and_mint_coin(admin);
        init_and_mint_coin(user1);

        // init pool for mock lending
        mock_aries::init_module_for_tests(admin);
        mock_aries::admin_add_pool<USDT>(admin);
        mock_aries::admin_add_pool<USDC>(admin);
        mock_aries::admin_add_pool<WBTC>(admin);
        mock_aries::admin_add_pool<STAPT>(admin);
        mock_aries::admin_add_pool<APT>(admin);
        mock_aries::admin_add_pool<WETH>(admin);
        mock_aries::admin_add_pool<CAKE>(admin);
        mock_aries::create_usdt_market<USDT>();
        mock_aries::create_usdc_market<USDC>();
        mock_aries::create_wbtc_market<WBTC>();
        mock_aries::create_stapt_market<STAPT>();
        mock_aries::create_apt_market<APT>();
        mock_aries::create_weth_market<WETH>();
        mock_aries::create_cake_market<CAKE>();

        mock_aries::deposit<USDT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<USDC>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<WBTC>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<STAPT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<APT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<WETH>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<CAKE>(admin, INITIAL_COIN_MOCK_POOL);

        // initialize storage
        storage::init_module_for_tests(admin);
        storage::create_market<USDT>(admin, 0, 0);
        storage::create_market<USDC>(admin, 0, 0);
        storage::create_market<WBTC>(admin, 0, 0);
        storage::create_market<STAPT>(admin, 0, 0);
        storage::create_market<APT>(admin, 0, 0);
        storage::create_market<WETH>(admin, 0, 0);
        storage::create_market<CAKE>(admin, 0, 0);

        utils::init_module_for_tests(admin);
    }

    // #[test(admin = @account, user1 = @0x1001, aptos_framework = @aptos_framework)]
    // public fun test_supply(
    //     admin: &signer, user1: &signer, aptos_framework: &signer
    // ) {
    //     test_init(admin, user1, aptos_framework);

    //     // user1 supply to pool
    //     entry_positions_manager::supply<USDT>(
    //         user1, signer::address_of(user1), 1000000, 100, ARIES_MARKET
    //     );
    //     let (p2p_supply, p2p_borrow) = storage::get_p2p_index<USDT>();
    //     // print(&p2p_supply);
    //     // print(&p2p_borrow);
    // }

    #[
        test(
            admin = @account,
            user1 = @0x1001,
            user2 = @0x1002,
            user3 = @0x1003,
            user4 = @0x1004,
            aptos_framework = @aptos_framework
        )
    ]
    public fun test_borrow(
        admin: &signer,
        user1: &signer,
        user2: &signer,
        user3: &signer,
        user4: &signer,
        aptos_framework: &signer
    ) {
        test_init(admin, user1, aptos_framework);

        // user1 supply to pool
        entry_positions_manager::supply<USDT>(
            user1, signer::address_of(user1), 1000000, 100, ARIES_MARKET
        );

        init_and_mint_coin(user2);
        init_and_mint_coin(user3);
        init_and_mint_coin(user4);

        entry_positions_manager::supply<USDT>(
            user2, signer::address_of(user2), 3000000, 100, ARIES_MARKET
        );

        entry_positions_manager::supply<USDT>(
            user3, signer::address_of(user3), 3000000, 100, ARIES_MARKET
        );

        entry_positions_manager::supply<WBTC>(
            user4, signer::address_of(user4), 10000000, 100, ARIES_MARKET
        );
        let (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();

        entry_positions_manager::borrow<USDT>(user4, 8000000, 100, ARIES_MARKET);
        (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();

        let hf = user_lens::get_health_factor(signer::address_of(user4), ARIES_MARKET);
        print(&string::utf8(b"Health Factor: "));
        print(&hf);
    }

    // #[
    //     test(
    //         admin = @account,
    //         user1 = @0x1001,
    //         user2 = @0x1002,
    //         user3 = @0x1003,
    //         user4 = @0x1004,
    //         aptos_framework = @aptos_framework
    //     )
    // ]
    // public fun test_borrow_before_supply(
    //     admin: &signer,
    //     user1: &signer,
    //     user2: &signer,
    //     user3: &signer,
    //     user4: &signer,
    //     aptos_framework: &signer
    // ) {
    //     test_init(admin, user1, aptos_framework);
    //     init_and_mint_coin(user2);
    //     init_and_mint_coin(user3);
    //     init_and_mint_coin(user4);
    
    //     // user1 supply to pool
    //     entry_positions_manager::supply<WBTC>(
    //         user1, signer::address_of(user1), 1000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::supply<USDC>(
    //         user2, signer::address_of(user2), 3000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::borrow<USDT>(user1, 1000000, 100, ARIES_MARKET);
    //     // print(&std::coin::balance<USDT>(signer::address_of(user1)));

    //     entry_positions_manager::borrow<USDT>(user2, 2000000, 100, ARIES_MARKET);
    //     // print(&std::coin::balance<USDT>(signer::address_of(user2)));

    //     entry_positions_manager::supply<USDT>(
    //         user3, signer::address_of(user3), 3500000, 100, ARIES_MARKET
    //     );

    //     let (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();
    //     // print(&p2psa);
    //     // print(&p2pba);
    // }

    // #[
    //     test(
    //         admin = @account,
    //         user1 = @0x1001,
    //         user2 = @0x1002,
    //         user3 = @0x1003,
    //         user4 = @0x1004,
    //         aptos_framework = @aptos_framework
    //     )
    // ]
    // public fun test_withdraw(
    //     admin: &signer,
    //     user1: &signer,
    //     user2: &signer,
    //     user3: &signer,
    //     user4: &signer,
    //     aptos_framework: &signer
    // ) {
    //     test_init(admin, user1, aptos_framework);
    //     init_and_mint_coin(user2);
    //     init_and_mint_coin(user3);
    //     init_and_mint_coin(user4);
    
    //     // user1 supply to pool
    //     entry_positions_manager::supply<USDT>(
    //         user1, signer::address_of(user1), 1000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::supply<USDT>(
    //         user2, signer::address_of(user2), 3000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::supply<USDC>(
    //         user3, signer::address_of(user3), 10000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::borrow<USDT>(
    //         user3, 8000000, 100, ARIES_MARKET
    //     );

    //     exit_positions_manager::withdraw<USDT>(
    //         user1, 500000, signer::address_of(user1), 100, ARIES_MARKET
    //     );

    //     // print(&std::coin::balance<USDT>(signer::address_of(user1)));
    // }
    // #[
    //     test(
    //         admin = @account,
    //         user1 = @0x1001,
    //         user2 = @0x1002,
    //         user3 = @0x1003,
    //         user4 = @0x1004,
    //         aptos_framework = @aptos_framework
    //     )
    // ]
    // public fun test_repay(
    //     admin: &signer,
    //     user1: &signer,
    //     user2: &signer,
    //     user3: &signer,
    //     user4: &signer,
    //     aptos_framework: &signer
    // ) {
    //     test_init(admin, user1, aptos_framework);
    //     init_and_mint_coin(user2);
    //     init_and_mint_coin(user3);
    //     init_and_mint_coin(user4);
    
    //     // user1 supply to pool
    //     entry_positions_manager::supply<USDT>(
    //         user1, signer::address_of(user1), 1000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::supply<USDT>(
    //         user2, signer::address_of(user2), 3000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::supply<USDC>(
    //         user3, signer::address_of(user3), 10000000, 100, ARIES_MARKET
    //     );

    //     entry_positions_manager::borrow<USDT>(
    //         user3, 8000000, 100, ARIES_MARKET
    //     );

    //     exit_positions_manager::repay<USDT>(
    //         user3, signer::address_of(user3), 5000000, 100, ARIES_MARKET
    //     );

    //     // print(&std::coin::balance<USDT>(signer::address_of(user3)));
    // }

}

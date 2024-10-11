module account::protocol_test {
    use std::signer;
    use std::vector;
    use account::entry_positions_manager;
    use account::exit_positions_manager;
    use account::mock_echelon;
    use account::storage;
    use account::user_lens;
    use account::aurita_coin::{Self, USDC, USDT, WBTC, STAPT, APT, WETH, CAKE};
    use aptos_framework::timestamp;
    use std::debug::print;
    use account::utils;
    use aptos_framework::account;
    use std::string;
    use std::type_info;

    const ERR_TEST: u64 = 1000;
    const INITIAL_COIN: u64 = 10000000000000; // 10^7
    const INITIAL_COIN_MOCK_POOL: u256 = 1000000000000; // 10^6
    const ECHELON_MARKET: u64 = 1;

    #[test_only]
    public fun init_and_mint_coin(sender: &signer) {
        let sender_addr = signer::address_of(sender);
        account::create_account_for_test(sender_addr);

        // coin::init<USDT>(sender);
        // coin::init<USDC>(sender);
        // coin::init<WBTC>(sender);
        // coin::init<STAPT>(sender);
        // coin::init<APT>(sender);
        // coin::init<WETH>(sender);
        // coin::init<CAKE>(sender);

        aurita_coin::mint<USDT>(sender, INITIAL_COIN);
        aurita_coin::mint<USDC>(sender, INITIAL_COIN);
        aurita_coin::mint<WBTC>(sender, INITIAL_COIN);
        aurita_coin::mint<STAPT>(sender, INITIAL_COIN);
        aurita_coin::mint<APT>(sender, INITIAL_COIN);
        aurita_coin::mint<WETH>(sender, INITIAL_COIN);
        aurita_coin::mint<CAKE>(sender, INITIAL_COIN);
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
        aurita_coin::init_module_for_tests(admin);
        init_and_mint_coin(admin);
        init_and_mint_coin(user1);

        // init pool for mock lending
        mock_echelon::init_module_for_tests(admin);
        mock_echelon::initialize_market(admin);

        // initialize storage
        storage::init_module_for_tests(admin);
        utils::init_module_for_tests(admin);
    }

    #[test(admin = @account, user1 = @0x1001, aptos_framework = @aptos_framework)]
    public fun test_supply(
        admin: &signer, user1: &signer, aptos_framework: &signer
    ) {
        test_init(admin, user1, aptos_framework);

        let user1_balance = user_lens::get_balance<USDT>(signer::address_of(user1));
        assert!(user1_balance == 10000000000000, ERR_TEST);

        // user1 supply to pool
        entry_positions_manager::supply<USDT>(
            user1, signer::address_of(user1), 1000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDC>(
            user1, signer::address_of(user1), 1000000, 100, ECHELON_MARKET
        );

        let total_supply = user_lens::get_total_supply<USDT>(signer::address_of(user1));
        assert!(total_supply == 1000000, ERR_TEST);

        let user1_supply_positions = user_lens::get_supply_positions(signer::address_of(user1));
        let user1_supply_numbers = vector::length(&user1_supply_positions);
        assert!(user1_supply_numbers == 2, ERR_TEST);
        let i = 0;
        while(i < user1_supply_numbers) {
            let coin_symbol = vector::borrow(&user1_supply_positions, (i as u64));
            // print(coin_symbol);
            i = i + 1;
        };
    }

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
            user1, signer::address_of(user1), 1000000, 100, ECHELON_MARKET
        );

        init_and_mint_coin(user2);
        init_and_mint_coin(user3);
        init_and_mint_coin(user4);
        

        entry_positions_manager::supply<USDT>(
            user2, signer::address_of(user2), 3000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDT>(
            user3, signer::address_of(user3), 3000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<CAKE>(
            user3, signer::address_of(user3), 3000000, 100, ECHELON_MARKET
        );

        // supply 10 Bitcoin = 635590 USDT
        entry_positions_manager::supply<WBTC>(
            user4, signer::address_of(user4), 10000000, 100, ECHELON_MARKET
        );
        let (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();

        // calculate borrowable
        let borrowable = user_lens::get_borrowable(signer::address_of(user4), ECHELON_MARKET);
        assert!(borrowable == 508472000000, ERR_TEST);

        // try borrow amount greater than borrowable amount
        entry_positions_manager::borrow<USDT>(user4, 508472000000, 100, ECHELON_MARKET);
        (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();


        // borrow 200000 USDT
        // entry_positions_manager::borrow<USDT>(user4, 200000000000, 100, ECHELON_MARKET);
        // (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();

        let total_borrow = user_lens::get_total_borrow<USDT>(signer::address_of(user4));
        // print(&total_borrow);
        assert!(total_borrow == 508472000000, ERR_TEST);

        let hf = exit_positions_manager::get_user_health_factor<USDT>(signer::address_of(user4), 0, ECHELON_MARKET);
        // print(&hf);
        assert!(hf == 1125000000000000000, ERR_TEST);

        let user_hf = user_lens::get_health_factor(signer::address_of(user4), ECHELON_MARKET);
        assert!(hf == 1125000000000000000, ERR_TEST);

        let borrow_positions_list = user_lens::get_borrow_positions(signer::address_of(user4));
        let supply_positions_list = user_lens::get_supply_positions(signer::address_of(user4));
        assert!(vector::length(&borrow_positions_list) == 1, ERR_TEST);
        assert!(vector::length(&supply_positions_list) == 1, ERR_TEST);
        let user4_borrow_numbers = vector::length(&borrow_positions_list);
        let i = 0;
        while(i < user4_borrow_numbers) {
            let coin_symbol = vector::borrow(&borrow_positions_list, (i as u64));
            // print(coin_symbol);
            i = i + 1;
        };

        let supply_positions_list = user_lens::get_supply_positions(signer::address_of(user3));
        assert!(vector::length(&supply_positions_list) == 2, ERR_TEST);

        let p2p_apy = user_lens::get_user_p2p_apy<WBTC>(ECHELON_MARKET);
        assert!(p2p_apy == 76000000000000000, ERR_TEST);
    }

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
    public fun test_borrow_before_supply(
        admin: &signer,
        user1: &signer,
        user2: &signer,
        user3: &signer,
        user4: &signer,
        aptos_framework: &signer
    ) {
        test_init(admin, user1, aptos_framework);
        init_and_mint_coin(user2);
        init_and_mint_coin(user3);
        init_and_mint_coin(user4);
    
        // user1 supply to pool
        entry_positions_manager::supply<WBTC>(
            user1, signer::address_of(user1), 1000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDC>(
            user2, signer::address_of(user2), 3000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::borrow<USDT>(user1, 1000000, 100, ECHELON_MARKET);
        // print(&std::coin::balance<USDT>(signer::address_of(user1)));

        entry_positions_manager::borrow<USDT>(user2, 2000000, 100, ECHELON_MARKET);
        // print(&std::coin::balance<USDT>(signer::address_of(user2)));

        entry_positions_manager::supply<USDT>(
            user3, signer::address_of(user3), 3500000, 100, ECHELON_MARKET
        );

        let (p2ps, p2pb, p2psa, p2pba) = storage::get_delta<USDT>();
        // print(&p2psa);
        // print(&p2pba);
    }

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
    public fun test_withdraw(
        admin: &signer,
        user1: &signer,
        user2: &signer,
        user3: &signer,
        user4: &signer,
        aptos_framework: &signer
    ) {
        test_init(admin, user1, aptos_framework);
        init_and_mint_coin(user2);
        init_and_mint_coin(user3);
        init_and_mint_coin(user4);
    
        // user1 supply to pool
        entry_positions_manager::supply<USDT>(
            user1, signer::address_of(user1), 1000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDT>(
            user2, signer::address_of(user2), 3000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDC>(
            user3, signer::address_of(user3), 10000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::borrow<USDT>(
            user3, 8000000, 100, ECHELON_MARKET
        );

        exit_positions_manager::withdraw<USDT>(
            user1, 500000, signer::address_of(user1), 100, ECHELON_MARKET
        );

        let total_supply = user_lens::get_total_supply<USDT>(signer::address_of(user1));
        assert!(total_supply == 1000000 - 500000, ERR_TEST);
        let user1_balance = std::coin::balance<USDT>(signer::address_of(user1));
        assert!(user1_balance == 9999999500000, ERR_TEST);

    }
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
    public fun test_repay(
        admin: &signer,
        user1: &signer,
        user2: &signer,
        user3: &signer,
        user4: &signer,
        aptos_framework: &signer
    ) {
        test_init(admin, user1, aptos_framework);
        init_and_mint_coin(user2);
        init_and_mint_coin(user3);
        init_and_mint_coin(user4);
    
        // user1 supply to pool
        entry_positions_manager::supply<USDT>(
            user1, signer::address_of(user1), 1000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDT>(
            user2, signer::address_of(user2), 3000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::supply<USDC>(
            user3, signer::address_of(user3), 10000000, 100, ECHELON_MARKET
        );

        entry_positions_manager::borrow<USDT>(
            user3, 8000000, 100, ECHELON_MARKET
        );

        exit_positions_manager::repay<USDT>(
            user3, signer::address_of(user3), 5000000, 100, ECHELON_MARKET
        );

        let total_borrow = user_lens::get_total_borrow<USDT>(signer::address_of(user3));
        assert!(total_borrow == 8000000 - 5000000, ERR_TEST);   
        
        let user3_balance = std::coin::balance<USDT>(signer::address_of(user3));
        assert!(user3_balance == 10000003000000, ERR_TEST);
    }
}

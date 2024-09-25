module account::protocol_test {
    use std::signer;
    use account::entry_positions_manager;
    use account::mock_lending;
    use account::storage;
    use account::coin::{Self, USDC, USDT, WBTC, STAPT};
    use aptos_framework::timestamp;
    use std::debug::print;
    use account::utils;

    const INITIAL_COIN: u64 = 10000000000000; // 10^7
    const INITIAL_COIN_MOCK_POOL: u256 = 1000000000000; // 10^6

    #[test_only]
    public fun init_and_mint_coin(sender: &signer) {
        let sender_addr = signer::address_of(sender);

        coin::init<USDT>(sender);
        coin::init<USDC>(sender);
        coin::init<WBTC>(sender);
        coin::init<STAPT>(sender);

        coin::mint<USDT>(sender_addr, INITIAL_COIN);
        coin::mint<USDC>(sender_addr, INITIAL_COIN);
        coin::mint<WBTC>(sender_addr, INITIAL_COIN);
        coin::mint<STAPT>(sender_addr, INITIAL_COIN);
    }

    #[test_only]
    public fun set_up_test_for_time(aptos_framework: &signer) {
        // set up global time for testing purpose
        timestamp::set_time_has_started_for_testing(aptos_framework);
    }
    
    #[test_only(admin = @account, user1 = @0x1001)]
    public fun test_init(admin: &signer, user1: &signer, aptos_framework: &signer) {
        
        // set up timestamp
        set_up_test_for_time(aptos_framework);    

        // mint coin for admin and user
        coin::initialize(admin);
        init_and_mint_coin(admin);
        init_and_mint_coin(user1);
        
        // init pool for mock lending
        mock_lending::init_module_for_tests(admin);
        mock_lending::admin_add_pool<USDT>(admin);
        mock_lending::admin_add_pool<USDC>(admin);
        mock_lending::admin_add_pool<WBTC>(admin);
        mock_lending::admin_add_pool<STAPT>(admin);
        mock_lending::create_usdt_market<USDT>();
        mock_lending::create_usdc_market<USDC>();
        mock_lending::create_wbtc_market<WBTC>();
        mock_lending::create_stapt_market<STAPT>();
        mock_lending::deposit<USDT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_lending::deposit<USDC>(admin, INITIAL_COIN_MOCK_POOL);
        mock_lending::deposit<WBTC>(admin, INITIAL_COIN_MOCK_POOL);
        mock_lending::deposit<STAPT>(admin, INITIAL_COIN_MOCK_POOL);

        // initialize storage
        storage::init_module_for_tests(admin);
        storage::create_market<USDT>(admin, 0, 0);
        storage::create_market<USDC>(admin, 0, 0);
        storage::create_market<WBTC>(admin, 0, 0);
        storage::create_market<STAPT>(admin, 0, 0);
    }

    #[test(admin = @account, user1 = @0x1001, aptos_framework = @aptos_framework)]
    public fun test_supply(admin: &signer, user1: &signer, aptos_framework: &signer) {
        test_init(admin, user1, aptos_framework);

        // user1 supply to pool
        entry_positions_manager::supply<USDT>(user1, signer::address_of(user1), 1000000, 100);
        print(&utils::get_user_supply_balance<USDT>(@0x1001));
        let (p2p_supply, p2p_borrow) = storage::get_p2p_index<USDT>();
        print(&p2p_supply);
        print(&p2p_borrow);
    }
}
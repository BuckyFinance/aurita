module account::mock_aries_test {
    use std::signer;
    use std::debug::print;
    use std::string;
    use account::mock_aries;
    use aptos_framework::coin::{Self, Coin};
    use coin_addr::aurita_coin::{Self, USDC, USDT, WBTC, STAPT, APT, WETH, CAKE};
    use aptos_framework::account;

    const BASE_12: u256 = 1000000000000;
    const ERR_TEST: u64 = 1000;
    const INITIAL_COIN: u64 = 10000000000000; // 10^7
    const INITIAL_COIN_MOCK_POOL: u256 = 1000000000000; // 10^6

    struct FakeAPT {}

    struct FreeCoins has key {
        apt_coin: Coin<FakeAPT>,
        apt_cap: coin::MintCapability<FakeAPT>,
        apt_burn: coin::BurnCapability<FakeAPT>,
        apt_freeze: coin::FreezeCapability<FakeAPT>
    }

    public fun init_fake_pools(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        let name = string::utf8(b"Aptos Token");
        let symbol = string::utf8(b"APT");
        let (apt_burn, apt_freeze, apt_cap) =
            coin::initialize<FakeAPT>(admin, name, symbol, 6, false);

        let mint_amount = 2000000000000;
        move_to(
            admin,
            FreeCoins {
                apt_coin: coin::mint<FakeAPT>(mint_amount, &apt_cap),
                apt_cap,
                apt_burn,
                apt_freeze
            }
        );
    }

    fun init_coin_stores(user: &signer) acquires FreeCoins {
        coin::register<FakeAPT>(user);
        let faucet_amount = 1000000000;
        let free_coins = borrow_global_mut<FreeCoins>(@account);
        let apt = coin::extract(&mut free_coins.apt_coin, faucet_amount);
        let addr = signer::address_of(user);
        coin::deposit(addr, apt);
    }

    public fun create_fake_user(user: &signer) acquires FreeCoins {
        init_coin_stores(user);
        let deposit_amount: u256 = 1000000000;
        mock_aries::deposit<FakeAPT>(user, 1000000000);
    }

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
    fun test_init(admin: &signer, user1: &signer) acquires FreeCoins {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user1);
        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);

        // admin add to pool
        init_fake_pools(admin);

        // create market for APT
        coin::register<FakeAPT>(admin);

        aurita_coin::init_module_for_tests(admin);
        init_and_mint_coin(admin);
        init_and_mint_coin(user1);

        mock_aries::init_module_for_tests(admin);
        mock_aries::initialize_market(admin);

        let free_coins = borrow_global_mut<FreeCoins>(admin_addr);
        let admin_deposit_amount: u256 = 1000000000000;
        let apt = coin::extract(&mut free_coins.apt_coin, (admin_deposit_amount as u64));
        coin::deposit<FakeAPT>(admin_addr, apt);
        mock_aries::deposit<FakeAPT>(admin, admin_deposit_amount);

        // user deposit to pool
        create_fake_user(user1);
    }

    #[test(sender = @account)]
    public fun test_market(sender: &signer) {
        mock_aries::init_module_for_tests(sender);
        mock_aries::create_apt_market<FakeAPT>();
        let (apt_deposit_apy, apt_borrow_apy) = mock_aries::get_market_apy<FakeAPT>();
    }

    #[test(admin = @account, user1 = @0x1001)]
    public fun test_deposit(admin: &signer, user1: &signer) {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(admin);
        // test_init(admin, user1);
        // let total_deposit = mock_aries::get_total_deposit<FakeAPT>();
        // assert!(total_deposit == 1001000000000, ERR_TEST);

        // let admin_balance = coin::balance<FakeAPT>(admin_addr);
        // let user_balance = coin::balance<FakeAPT>(user1_addr);
        // let lending_protocol_balance = coin::balance<FakeAPT>(@account);
        // print(&admin_balance);
        // print(&user_balance);
        // print(&lending_protocol_balance);
    }

    #[test(admin = @account, user1 = @0x1001)]
    public fun test_withdraw(admin: &signer, user1: &signer) {
        let user1_addr = signer::address_of(user1);
        mock_aries::init_module_for_tests(admin);
        // test_init(admin, user1);
        // let total_deposit = mock_aries::get_total_deposit<FakeAPT>();
        // print(&total_deposit);
        // assert!(total_deposit == 1000000000000, ERR_TEST);

        // let user_balance = coin::balance<FakeAPT>(user1_addr);
        // assert!(user_balance == 1000000000, ERR_TEST);
    }
}

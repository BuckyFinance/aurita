module account::mock_lending_test {
    use std::signer;
    use std::debug::print;
    use std::string;
    use account::mock_lending;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::account;

    const ERR_TEST: u64 = 1000;

    struct FakeAPT {}

    struct FreeCoins has key {
        apt_coin: Coin<FakeAPT>,
        apt_cap: coin::MintCapability<FakeAPT>,
        apt_burn: coin::BurnCapability<FakeAPT>,
        apt_freeze: coin::FreezeCapability<FakeAPT>,
    }

    public entry fun init_fake_pools(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        let name = string::utf8(b"Aptos Token");
        let symbol = string::utf8(b"APT");
        let (apt_burn, apt_freeze, apt_cap) = coin::initialize<FakeAPT>(admin, name, symbol, 6, false);

        let mint_amount = 2000000000000;
        move_to(admin, FreeCoins {
            apt_coin: coin::mint<FakeAPT>(mint_amount, &apt_cap),
            apt_cap,
            apt_burn,
            apt_freeze,
        });
    }

    fun init_coin_stores(user: &signer) acquires FreeCoins {
        coin::register<FakeAPT>(user);
        let faucet_amount = 1000000000;
        let free_coins = borrow_global_mut<FreeCoins>(@account);
        let apt = coin::extract(&mut free_coins.apt_coin, faucet_amount);
        let addr = signer::address_of(user);
        coin::deposit(addr, apt);
    }

    public entry fun create_fake_user(user: &signer) acquires FreeCoins {
        init_coin_stores(user);
        let deposit_amount = 1000000000;
        let market_name = string::utf8(b"APT");
        mock_lending::deposit<FakeAPT>(user, market_name, 1000000000);
    }
    
    #[test_only]
    fun test_init(admin: &signer, user1: &signer) acquires FreeCoins {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user1);
        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);

        // admin add to pool
        init_fake_pools(admin);
        mock_lending::admin_add_pool<FakeAPT>(admin);
        coin::register<FakeAPT>(admin);
        let market_name = string::utf8(b"APT");
        let free_coins = borrow_global_mut<FreeCoins>(admin_addr);
        let admin_deposit_amount = 1000000000000;
        let apt = coin::extract(&mut free_coins.apt_coin, admin_deposit_amount);
        coin::deposit<FakeAPT>(admin_addr, apt);
        mock_lending::deposit<FakeAPT>(admin, market_name, admin_deposit_amount);

        // user deposit to pool
        create_fake_user(user1);
    }
    
    #[test(sender = @account)]
    public fun test_market(sender: &signer) {
        mock_lending::init_module_for_tests(sender);
        let usdt_markt_name = string::utf8(b"USDT");
        let (usdt_deposit_apy, usdt_borrow_apy) = mock_lending::get_market_apy(usdt_markt_name);

        assert!(usdt_deposit_apy == 47000, ERR_TEST);
        assert!(usdt_borrow_apy == 81300, ERR_TEST);

        let apt_market_name = string::utf8(b"APT");
        let (apt_deposit_apy, apt_borrow_apy) = mock_lending::get_market_apy(apt_market_name);
        assert!(apt_deposit_apy == 23800, ERR_TEST);
        assert!(apt_borrow_apy == 50500, ERR_TEST);
    }

    #[test(admin=@account, user1=@0x1001)]
    public entry fun test_deposit(admin: &signer, user1: &signer) acquires FreeCoins {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(admin);
        mock_lending::init_module_for_tests(admin);
        test_init(admin, user1);
        let market_name = string::utf8(b"APT");
        let total_deposit = mock_lending::get_total_deposit(market_name);
        assert!(total_deposit == 1001000000000, ERR_TEST);

        let admin_balance = coin::balance<FakeAPT>(admin_addr);
        let user_balance = coin::balance<FakeAPT>(user1_addr);
        let lending_protocol_balance = coin::balance<FakeAPT>(@account);
        // print(&admin_balance);
        // print(&user_balance);
        // print(&lending_protocol_balance);
    }

    #[test(admin=@account, user1=@0x1001)]
    public entry fun test_withdraw(admin: &signer, user1: &signer) acquires FreeCoins {
        let user1_addr = signer::address_of(user1);
        mock_lending::init_module_for_tests(admin);
        test_init(admin, user1);
        let market_name = string::utf8(b"APT");
        mock_lending::withdraw<FakeAPT>(user1, market_name, 1000000000);
        let total_deposit = mock_lending::get_total_deposit(market_name);
        // print(&total_deposit);
        assert!(total_deposit == 1000000000000, ERR_TEST);

        let user_balance = coin::balance<FakeAPT>(user1_addr);
        assert!(user_balance == 1000000000, ERR_TEST);
    }

}
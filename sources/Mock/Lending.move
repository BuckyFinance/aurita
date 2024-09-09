module account::mock_lending {
    use std::string::{Self, String};
    use std::signer;
    use std::vector;
    use aptos_framework::coin::{Self, Coin};
    use std::simple_map::{Self, SimpleMap};

    const ERR: u64 = 1000;

    friend account::mock_lending_test;

    struct MarketReserve<phantom CoinType> has key {
        reserve: Coin<CoinType>,
    }

    struct Market has key, store {
        total_deposit: u64,
        deposit_apy: u64,
        borrow_apy: u64,
    }

    struct MarketRecord has key {
        market_list: vector<String>,
        market_map: SimpleMap<String, Market>,
    }

    fun init_module(sender: &signer) acquires MarketRecord {
        move_to(sender, MarketRecord {
            market_list: vector::empty(),
            market_map: simple_map::create(),
        });

        // create USDT market
        create_market(
            sender,
            string::utf8(b"USDT"),
            47000, // 4.7% APY
            81300, // 8.13% APY
        );

        // create USDC market
        create_market(
            sender,
            string::utf8(b"USDC"),
            46600, // 4.66% APY
            81000, // 8.10% APY
        );

        // create WBTC market
        create_market(
            sender,
            string::utf8(b"WBTC"),
            9800, // 0.98% APY
            43400, // 4.34% APY
        );

        // create APT market
        create_market(
            sender,
            string::utf8(b"APT"),
            23800, // 2.38% APY
            50500, // 5.05% APY
        );

        // create stAPT market
        create_market(
            sender,
            string::utf8(b"stAPT"),
            22300, // 2.23% APY
            49400, // 4.94% APY
        );

    }

    // ===============================================================================
    // ============================= Entry Function ==================================
    // ===============================================================================

    public entry fun admin_add_pool<CoinType>(sender: &signer) {
        move_to<MarketReserve<CoinType>>(sender, MarketReserve<CoinType> {
            reserve: coin::zero<CoinType>(),
        });
    }

    public entry fun deposit<CoinType>(sender: &signer, market_name: String, amount: u64) acquires MarketRecord, MarketReserve {
        let sender_addr = signer::address_of(sender);
        let market_map = &mut borrow_global_mut<MarketRecord>(@account).market_map;
        let market = simple_map::borrow_mut<String, Market>(market_map, &market_name);
        market.total_deposit = market.total_deposit + amount;

        // withdraw from user wallet
        let coin = coin::withdraw<CoinType>(sender, amount);
        let reserve = &mut borrow_global_mut<MarketReserve<CoinType>>(@account).reserve;
        coin::merge(reserve, coin);
    }

    public entry fun withdraw<CoinType>(sender: &signer, market_name: String, amount: u64) acquires MarketRecord, MarketReserve {
        let sender_addr = signer::address_of(sender);
        let market_map = &mut borrow_global_mut<MarketRecord>(@account).market_map;
        let market = simple_map::borrow_mut<String, Market>(market_map, &market_name);
        assert!(market.total_deposit >= amount, ERR);
        market.total_deposit = market.total_deposit - amount;

        // deposit to user wallet
        let reserve = &mut borrow_global_mut<MarketReserve<CoinType>>(@account).reserve;
        let coin = coin::extract(reserve, amount);
        coin::deposit(sender_addr, coin);
    }

    public entry fun borrow<CoinType>(sender: &signer, market_name: String, amount: u64) acquires MarketRecord, MarketReserve {
        withdraw<CoinType>(sender, market_name, amount);
    }

    public entry fun repay<CoinType>(sender: &signer, market_name: String, amount: u64) acquires MarketRecord, MarketReserve{
        deposit<CoinType>(sender, market_name, amount);
    }

    // ================================================================================
    // ============================= Helper Function ==================================
    // ================================================================================

    public fun create_market(
        sender: &signer,
        market_name: String,
        deposit_apy: u64,
        borrow_apy: u64,
    ) acquires MarketRecord{
        let market_record = borrow_global_mut<MarketRecord>(@account);
        let market_list = &mut market_record.market_list;
        let market_map = &mut market_record.market_map;
        vector::push_back(market_list, market_name);
        let market = Market {
            total_deposit: 0,
            deposit_apy: deposit_apy,
            borrow_apy: borrow_apy,
        };
        simple_map::add(market_map, market_name, market);
    }

    // ==============================================================================
    // ============================= View Function ==================================
    // ==============================================================================

    #[view]
    public fun get_market_apy(market_name: String): (u64, u64) acquires MarketRecord {
        let market_record = borrow_global<MarketRecord>(@account);
        let market_map = &market_record.market_map;
        let market = simple_map::borrow(market_map, &market_name);
        (market.deposit_apy, market.borrow_apy)
    }

    #[view]
    public fun get_total_deposit(market_name: String): u64 acquires MarketRecord {
        let market_record = borrow_global<MarketRecord>(@account);
        let market_map = &market_record.market_map;
        let market = simple_map::borrow(market_map, &market_name);
        market.total_deposit
    }

    #[view]
    public fun get_pool_supply_index(market_name: String): u64 {
        let pool_supply_index = 1;
        pool_supply_index
    }

    #[view]
    public fun get_borrow_supply_index(market_name: String): u64 {
        let borrow_supply_index = 1;
        borrow_supply_index
    }

    #[test_only(sender = @account)]
    public fun init_module_for_tests(sender: &signer) acquires MarketRecord {
        init_module(sender);
    }


}
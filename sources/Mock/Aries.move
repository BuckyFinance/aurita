module account::mock_aries {
    use std::string::{Self, String};
    use std::signer;
    use std::vector;
    use std::debug::print;
    use aptos_framework::coin::{Self, Coin};
    use std::simple_map::{Self, SimpleMap};
    use aptos_std::type_info::{Self, TypeInfo, type_of};
    use coin_addr::aurita_coin::{Self, USDC, USDT, WBTC, STAPT, APT, WETH, CAKE};

    const ERR: u64 = 1000;
    const BASE_6: u64 = 1000000;
    const BASE_12: u256 = 1000000000000;
    const INITIAL_COIN: u256 = 1000000000000000000; // 10^12

    struct MarketReserve<phantom CoinType> has key {
        reserve: Coin<CoinType>
    }

    struct Market has key, store {
        total_deposit: u256,
        deposit_apy: u256,
        borrow_apy: u256
    }

    struct SupplyPosition has key, store , drop{
        supply_list: vector<TypeInfo>,
        supply_map: SimpleMap<TypeInfo, u256>
    }

    struct PositionRecord has key {
        supply_record: SimpleMap<address, SupplyPosition>
    }

    struct MarketRecord has key {
        market_list: vector<TypeInfo>,
        market_map: SimpleMap<TypeInfo, Market>
    }

    fun init_module(sender: &signer) {
        move_to(
            sender,
            MarketRecord {
                market_list: vector::empty(),
                market_map: simple_map::create()
            }
        );

        move_to(
            sender,
            PositionRecord {
                supply_record: simple_map::create()
            }
        );

        admin_add_pool<USDT>(sender);
        admin_add_pool<USDC>(sender);
        admin_add_pool<WBTC>(sender);
        admin_add_pool<STAPT>(sender);
        admin_add_pool<APT>(sender);
        admin_add_pool<WETH>(sender);
        admin_add_pool<CAKE>(sender);
    }

    // ===============================================================================
    // ============================= Entry Function ==================================
    // ===============================================================================

    public entry fun initialize_market(sender: &signer) acquires MarketRecord, MarketReserve {
        create_usdt_market<USDT>();
        create_usdc_market<USDC>();
        create_wbtc_market<WBTC>();
        create_stapt_market<STAPT>();
        create_apt_market<APT>();
        create_weth_market<WETH>();
        create_cake_market<CAKE>();

        aurita_coin::mint<USDT>(sender, (INITIAL_COIN as u64));
        aurita_coin::mint<USDC>(sender, (INITIAL_COIN as u64));
        aurita_coin::mint<WBTC>(sender, (INITIAL_COIN as u64));
        aurita_coin::mint<STAPT>(sender, (INITIAL_COIN as u64));
        aurita_coin::mint<APT>(sender, (INITIAL_COIN as u64));
        aurita_coin::mint<WETH>(sender, (INITIAL_COIN as u64));
        aurita_coin::mint<CAKE>(sender, (INITIAL_COIN as u64));

        deposit<USDT>(sender, 187845757620000);
        deposit<USDC>(sender, 193859095050000);
        deposit<WBTC>(sender, 10700000000);
        deposit<STAPT>(sender, 11023373230000);
        deposit<APT>(sender, 7054616740000);
        deposit<WETH>(sender, 606700000);
        deposit<CAKE>(sender, 2202510840000);
    }

    public fun admin_add_pool<CoinType>(sender: &signer) {
        move_to<MarketReserve<CoinType>>(
            sender,
            MarketReserve<CoinType> {
                reserve: coin::zero<CoinType>()
            }
        );
    }

    public fun create_usdt_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 53100 * BASE_12, 86400 * BASE_12);
    }

    public fun create_usdc_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 46300 * BASE_12, 80700 * BASE_12);
    }

    public fun create_wbtc_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 21900 * BASE_12, 64900 * BASE_12);
    }

    public fun create_apt_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 22800 * BASE_12, 49500 * BASE_12);
    }

    public fun create_stapt_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 0 * BASE_12,  500 * BASE_12);
    }
    
    public fun create_weth_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 7000 * BASE_12, 27800 * BASE_12);
    }

    public fun create_cake_market<CoinType>() acquires MarketRecord {
        let coin_type = type_of<CoinType>();
        create_market(coin_type, 0 * BASE_12, 1700 * BASE_12);
    }

    public fun deposit<CoinType>(sender: &signer, amount: u256) acquires MarketRecord, MarketReserve {
        let sender_addr = signer::address_of(sender);
        let market_map = &mut borrow_global_mut<MarketRecord>(@account).market_map;
        let coin_type = type_of<CoinType>();
        let market = simple_map::borrow_mut<TypeInfo, Market>(market_map, &coin_type);
        market.total_deposit = market.total_deposit + amount;

        // withdraw from user wallet
        let coin = coin::withdraw<CoinType>(sender, (amount as u64));
        let reserve = &mut borrow_global_mut<MarketReserve<CoinType>>(@account).reserve;
        coin::merge(reserve, coin);
    }

    public entry fun user_deposit<CoinType>(sender: &signer, amount: u256) acquires MarketRecord, MarketReserve, PositionRecord {
        let sender_addr = signer::address_of(sender);
        let supply_record = &mut borrow_global_mut<PositionRecord>(@account).supply_record;
        let market_map = &mut borrow_global_mut<MarketRecord>(@account).market_map;
        let coin_type = type_of<CoinType>();
        let market = simple_map::borrow_mut<TypeInfo, Market>(market_map, &coin_type);
        market.total_deposit = market.total_deposit + amount;

        // store supply position
        if (!simple_map::contains_key(supply_record, &sender_addr)) {
            let supply_list = vector::empty<TypeInfo>();
            vector::push_back(&mut supply_list, coin_type);

            let supply_map = simple_map::create<TypeInfo, u256>();
            simple_map::add(&mut supply_map, coin_type, amount);

            let supply_position = SupplyPosition {
                supply_list,
                supply_map
            };

            simple_map::add(supply_record, sender_addr, supply_position);
        } else {
            let supply_position = simple_map::borrow_mut<address, SupplyPosition>(supply_record, &sender_addr);

            let supply_list = &mut supply_position.supply_list;
            let supply_map = &mut supply_position.supply_map;

            if (!vector::contains(supply_list, &coin_type)) {
                vector::push_back(supply_list, coin_type);
                simple_map::add(supply_map, coin_type, amount);
            } else {
                let new_amount = simple_map::borrow_mut<TypeInfo, u256>(supply_map, &coin_type);
                *new_amount = *new_amount + amount;
            }
        };

        
        // withdraw from user wallet
        let coin = coin::withdraw<CoinType>(sender, (amount as u64));
        let reserve = &mut borrow_global_mut<MarketReserve<CoinType>>(@account).reserve;
        coin::merge(reserve, coin);
    }

    public fun withdraw<CoinType>(
        sender: &signer, amount: u256
    ): Coin<CoinType> acquires MarketRecord, MarketReserve {
        let sender_addr = signer::address_of(sender);
        let market_map = &mut borrow_global_mut<MarketRecord>(@account).market_map;
        let coin_type = type_of<CoinType>();
        let market = simple_map::borrow_mut<TypeInfo, Market>(market_map, &coin_type);
        assert!(market.total_deposit >= amount, ERR);
        market.total_deposit = market.total_deposit - amount;

        // deposit to user wallet
        let reserve = &mut borrow_global_mut<MarketReserve<CoinType>>(@account).reserve;
        let coin = coin::extract(reserve, (amount as u64));
        coin
    }

    public entry fun user_withdraw<CoinType>(
        sender: &signer, amount: u256
    ) acquires MarketRecord, MarketReserve, PositionRecord {
        let sender_addr = signer::address_of(sender);
        let market_map = &mut borrow_global_mut<MarketRecord>(@account).market_map;
        let supply_record = &mut borrow_global_mut<PositionRecord>(@account).supply_record;
        let coin_type = type_of<CoinType>();
        let market = simple_map::borrow_mut<TypeInfo, Market>(market_map, &coin_type);
        assert!(market.total_deposit >= amount, ERR);
        market.total_deposit = market.total_deposit - amount;

        // update poistion record storage
        assert!(simple_map::contains_key<address, SupplyPosition>(supply_record, &sender_addr), ERR);
        let supply_position = simple_map::borrow_mut<address, SupplyPosition>(supply_record, &sender_addr);
        let supply_list = &mut supply_position.supply_list;
        let supply_map = &mut supply_position.supply_map;
        let new_amount = simple_map::borrow_mut<TypeInfo, u256>(supply_map, &coin_type);
        *new_amount = *new_amount - amount;
        if(*new_amount == 0) {
            vector::remove_value(supply_list, &coin_type);
            simple_map::remove<TypeInfo, u256>(supply_map, &coin_type);
        };

        // deposit to user wallet
        let reserve = &mut borrow_global_mut<MarketReserve<CoinType>>(@account).reserve;
        let coin = coin::extract(reserve, (amount as u64));
        coin::deposit(sender_addr, coin);
    }

    public fun borrow<CoinType>(
        sender: &signer, amount: u256
    ): Coin<CoinType> acquires MarketRecord, MarketReserve {
        let coin = withdraw<CoinType>(sender, amount);
        coin
    }

    public fun repay<CoinType>(sender: &signer, amount: u256) acquires MarketRecord, MarketReserve {
        deposit<CoinType>(sender, amount);
    }

    // ================================================================================
    // ============================= Helper Function ==================================
    // ================================================================================

    public fun create_market(
        coin_type: TypeInfo, deposit_apy: u256, borrow_apy: u256
    ) acquires MarketRecord {
        let market_record = borrow_global_mut<MarketRecord>(@account);
        let market_list = &mut market_record.market_list;
        let market_map = &mut market_record.market_map;
        vector::push_back(market_list, coin_type);
        let market = Market {
            total_deposit: 0,
            deposit_apy: deposit_apy,
            borrow_apy: borrow_apy
        };
        simple_map::add(market_map, coin_type, market);
    }

    // ==============================================================================
    // ============================= View Function ==================================
    // ==============================================================================

    #[view]
    public fun get_market_apy<CoinType>(): (u256, u256) acquires MarketRecord {
        let market_record = borrow_global<MarketRecord>(@account);
        let market_map = &market_record.market_map;
        let coin_type = type_of<CoinType>();
        let market = simple_map::borrow(market_map, &coin_type);
        (market.deposit_apy, market.borrow_apy)
    }

    #[view]
    public fun get_market_configuration(): (u256, u256) {
        let ltv = 800000 * BASE_12;
        let liquidation_threshold = 900000 * BASE_12;
        (ltv, liquidation_threshold)
    }

    #[view]
    public fun get_total_deposit<CoinType>(): u256 acquires MarketRecord {
        let market_record = borrow_global<MarketRecord>(@account);
        let market_map = &market_record.market_map;
        let coin_type = type_of<CoinType>();
        let market = simple_map::borrow(market_map, &coin_type);
        market.total_deposit
    }

    #[view]
    public fun get_pool_supply_index<CoinType>(): u256 {
        let pool_supply_index = 3000000000000000900;
        pool_supply_index
    }

    #[view]
    public fun get_pool_borrow_index<CoinType>(): u256 {
        let pool_borrow_index = 3000000000000011000;
        pool_borrow_index
    }

    #[view]
    public fun get_coin_deposit(sender_addr: address): vector<String>  acquires PositionRecord{
        let supply_record = &borrow_global<PositionRecord>(@account).supply_record;
        let supply_position = simple_map::borrow(supply_record, &sender_addr);
        let supply_list = &supply_position.supply_list;
        let coin_symbol_list: vector<String> = vector::empty();
        let supply_numbers = vector::length(supply_list);
        let i = 0;
        while(i < supply_numbers) {
            let coin_type = vector::borrow(supply_list, (i as u64));
            let coin_symbol = type_info::struct_name(coin_type);
            let coin_symbol_string = string::utf8(coin_symbol);
            vector::push_back(&mut coin_symbol_list, coin_symbol_string);
            i = i + 1;
        };
        coin_symbol_list
    }

    #[view]
    public fun get_amount_deposit(sender_addr: address): vector<u256>  acquires PositionRecord{
        let supply_record = &borrow_global<PositionRecord>(@account).supply_record;
        let supply_position = simple_map::borrow(supply_record, &sender_addr);
        let supply_list = &supply_position.supply_list;
        let supply_map = &supply_position.supply_map;
        let amount_list: vector<u256> = vector::empty();
        let supply_numbers = vector::length(supply_list);
        let i = 0;
        while(i < supply_numbers) {
            let coin_type = vector::borrow(supply_list, (i as u64));
            let amount = simple_map::borrow(supply_map, coin_type);
            vector::push_back(&mut amount_list, *amount);
            i = i + 1;
        };
        amount_list
    }

    #[test_only(sender = @account)]
    public fun init_module_for_tests(sender: &signer) {
        init_module(sender);
    }
}

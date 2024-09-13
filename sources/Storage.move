module account::Storage {
    use std::signer;
    use std::timestamp;
    use std::vector;
    use std::simple_map::{Self, SimpleMap};
    use aptos_std::type_info::{TypeInfo, type_of};

    friend account::Utils;

    struct Index<phantom CoinType> has key {
        last_update_timestamp: u64,
        pool_supply_index: u128,
        pool_borrow_index: u128,
        p2p_supply_index: u128,
        p2p_borrow_index: u128,
    }

    struct Market<phantom CoinType> has key {
        reserve_factor: u16,
        p2p_cursor: u16,
    }

    struct MarketCreated has key {
        market_created_list: vector<TypeInfo>,
    }

    struct SuppliersInP2P<phantom CoinType> has key {
        heap_array: vector<address>,
    }

    struct SuppliersOnPool<phantom CoinType> has key {
        heap_array: vector<address>,
    }

    struct BorrowersInP2P<phantom CoinType> has key {
        heap_array: vector<address>,
    }

    struct BorrowersOnPool<phantom CoinType> has key {
        heap_array: vector<address>,
    }

    struct SupplyBalance has key, store {
        in_p2p: u256,
        on_pool: u256,
    }

    struct BorrowBalance has key, store {
        in_p2p: u256,
        on_pool: u256,
    }

    struct SupplyRecord<phantom CoinType> has key {
        supply_map: SimpleMap<address, SupplyBalance>
    }

    struct BorrowRecord<phantom CoinType> has key {
        borrow_map: SimpleMap<address, BorrowBalance>
    }

    struct MaxGasForMatching<phantom CoinType> has key {
        supply: u64,
        borrow: u64,
        withdraw: u64,
        repay: u64,
    }

    struct Delta<phantom CoinType> has key {
        p2p_supply_delta: u256,
        p2p_borrow_delta: u256,
        p2p_supply_amount: u256,
        p2p_borrow_amount: u256,
    }

    // no need to put into storage
    struct AssetLiquidityData has key {
        decimals: u64,
        token_unit: u64,
        liquidation_threshold: u64,
        ltv: u64,
        underlying_price: u64,
        collateral_eth: u64,
        debt_eth: u64,
    }

    // no need to put into storage
    struct LiquidityData has key {
        collateral_eth: u64,
        borrowable_eth: u64,
        max_debt_eth: u64,
        debt_eth: u64,
    }

    const ENOT_OWNER: u64 = 1;
    const EMARKET_EXIST: u64 = 2;
    const EMARKET_NOT_EXIST: u64 = 3;

    fun init_module(sender: &signer) {
        move_to(sender, MarketCreated {
            market_created_list: vector::empty(),
        });
    } 

    /// @ducanh2706 refactor later
    public fun create_market<CoinType>(owner: &signer, reserve_factor: u16, p2p_cursor: u16) acquires MarketCreated {
        assert!(signer::address_of(owner) == @account, ENOT_OWNER);
        assert!(!exists<Market<CoinType>>(@account), EMARKET_EXIST);

        let market_created_list = &mut borrow_global_mut<MarketCreated>(@account).market_created_list;
        vector::push_back(market_created_list, type_of<CoinType>());

        move_to(owner, Market<CoinType> {
            reserve_factor,
            p2p_cursor,
        });

        move_to(owner, MarketCreated {
            market_created_list: vector::empty(),
        });

        /// @ducanh2706 have to fix later (get index by calling pool)
        move_to(owner, Index<CoinType> {
            last_update_timestamp: timestamp::now_seconds(), 
            pool_supply_index: 1000000000000000000,
            pool_borrow_index: 1000000000000000000,
            p2p_supply_index: 1000000000000000000,
            p2p_borrow_index: 1000000000000000000,
        });

        move_to(owner, SupplyRecord<CoinType> {
            supply_map: simple_map::create()
        });

        move_to(owner, BorrowRecord<CoinType> {
            borrow_map: simple_map::create()
        });

        move_to(owner, MaxGasForMatching<CoinType> {
            supply: 0,
            borrow: 0,
            withdraw: 0,
            repay: 0,
        });

        move_to(owner, Delta<CoinType> {
            p2p_supply_delta: 0,
            p2p_borrow_delta: 0,
            p2p_supply_amount: 0,
            p2p_borrow_amount: 0,
        });

        move_to(owner, SuppliersInP2P<CoinType> {
            heap_array: vector::empty(),
        });

         move_to(owner, SuppliersOnPool<CoinType> {
            heap_array: vector::empty(),
        });

         move_to(owner, BorrowersInP2P<CoinType> {
            heap_array: vector::empty(),
        });

         move_to(owner, BorrowersOnPool<CoinType> {
            heap_array: vector::empty(),
        });

    }

    public fun set_index<CoinType>(last_update_timestamp: u64, pool_supply_index: u128, pool_borrow_index: u128) acquires Index {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let pool_index = borrow_global_mut<Index<CoinType>>(@account);
        pool_index.last_update_timestamp = last_update_timestamp;
        pool_index.pool_supply_index = pool_supply_index;
        pool_index.pool_borrow_index = pool_borrow_index;
        pool_index.p2p_supply_index = (pool_supply_index + pool_borrow_index) / 2;
        pool_index.p2p_borrow_index = (pool_supply_index + pool_borrow_index) / 2;
    }

    // @todo
    public fun update_index<CoinType>() {
        
    }

    public fun add_supplier_in_p2p<CoinType>(supplier: address) acquires SuppliersInP2P {
        let heap_array = &mut borrow_global_mut<SuppliersInP2P<CoinType>>(@account).heap_array;
        vector::push_back(heap_array, supplier);
    }

    public fun add_supplier_on_pool<CoinType>(supplier: address) acquires SuppliersOnPool {
        let heap_array = &mut borrow_global_mut<SuppliersOnPool<CoinType>>(@account).heap_array;
        vector::push_back(heap_array, supplier);
    }

    public fun add_borrower_in_p2p<CoinType>(supplier: address) acquires BorrowersInP2P {
        let heap_array = &mut borrow_global_mut<BorrowersInP2P<CoinType>>(@account).heap_array;
        vector::push_back(heap_array, supplier);
    }

    public fun add_borrower_on_pool<CoinType>(supplier: address) acquires BorrowersOnPool {
        let heap_array = &mut borrow_global_mut<BorrowersOnPool<CoinType>>(@account).heap_array;
        vector::push_back(heap_array, supplier);
    }

    public fun add_supply_record<CoinType>(sender_addr: address, in_p2p: u256, on_pool: u256) acquires SupplyRecord {
        let supply_balance = SupplyBalance {
            in_p2p: in_p2p,
            on_pool: on_pool,
        };
        let supply_map = &mut borrow_global_mut<SupplyRecord<CoinType>>(@account).supply_map;
        simple_map::add(supply_map, sender_addr, supply_balance);
    }

    public fun update_supply_record<CoinType>(sender_addr: address, in_p2p: u256, on_pool: u256) acquires SupplyRecord {
        let supply_map = &mut borrow_global_mut<SupplyRecord<CoinType>>(@account).supply_map;
        let supply_balance = simple_map::borrow_mut<address, SupplyBalance>(supply_map, &sender_addr);
        supply_balance.in_p2p = in_p2p;
        supply_balance.on_pool = on_pool;
    }

    public fun add_borrow_record<CoinType>(sender_addr: address, in_p2p: u256, on_pool: u256) acquires BorrowRecord {
        let borrow_balance = BorrowBalance {
            in_p2p: in_p2p,
            on_pool: on_pool,
        };
        let borrow_map = &mut borrow_global_mut<BorrowRecord<CoinType>>(@account).borrow_map;
        simple_map::add(borrow_map, sender_addr, borrow_balance);
    }

    public fun update_borrow_record<CoinType>(sender_addr: address, in_p2p: u256, on_pool: u256) acquires BorrowRecord {
        let borrow_map = &mut borrow_global_mut<BorrowRecord<CoinType>>(@account).borrow_map;
        let borrow_balance = simple_map::borrow_mut<address, BorrowBalance>(borrow_map, &sender_addr);
        borrow_balance.in_p2p = in_p2p;
        borrow_balance.on_pool = on_pool;
    }

    public fun set_max_gas_for_matching<CoinType>(supply: u64, borrow: u64, withdraw: u64, repay: u64) acquires MaxGasForMatching {
        let max_gas = borrow_global_mut<MaxGasForMatching<CoinType>>(@account);
        max_gas.supply = supply;
        max_gas.borrow = borrow;
        max_gas.withdraw = withdraw;
        max_gas.repay = repay;
    }

    public fun set_delta<CoinType>(supply_delta: u256, borrow_delta: u256, supply_amount: u256, borrow_amount: u256) acquires Delta {
        let delta = borrow_global_mut<Delta<CoinType>>(@account);
        delta.p2p_supply_delta = supply_delta;
        delta.p2p_borrow_delta = borrow_delta;
        delta.p2p_supply_amount = supply_amount;
        delta.p2p_borrow_amount = borrow_amount;
    }

    //=======================================================================================
    //================================ Getter Function ======================================
    //=======================================================================================

    #[view]
    public fun get_all_markets(): vector<TypeInfo> acquires MarketCreated{
        let market_created_list = borrow_global<MarketCreated>(@account).market_created_list;
        market_created_list
    }

    #[view]
    public fun getpool_index<CoinType>(): (u128, u128) acquires Index {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let pool_index = borrow_global<Index<CoinType>>(@account);
        (pool_index.pool_supply_index, pool_index.pool_borrow_index)
    }

    #[view] 
    public fun getP2PIndex<CoinType>(): (u128, u128) acquires Index {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let pool_index = borrow_global<Index<CoinType>>(@account);
        (pool_index.p2p_supply_index, pool_index.p2p_borrow_index)
    }

    #[view]
    public fun getMarket<CoinType>(): (u16, u16) acquires Market {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let market = borrow_global<Market<CoinType>>(@account);
        (market.reserve_factor, market.p2p_cursor)
    }

    #[view]
    public fun get_head_supplier_in_p2p<CoinType>(): address acquires SuppliersInP2P {
        let heap_array = &borrow_global<SuppliersInP2P<CoinType>>(@account).heap_array;
        *vector::borrow(heap_array, 0)
    }

    #[view]
    public fun get_head_supplier_on_pool<CoinType>(): address acquires SuppliersOnPool {
        let heap_array = &borrow_global<SuppliersOnPool<CoinType>>(@account).heap_array;
        *vector::borrow(heap_array, 0)
    }

    #[view]
    public fun get_head_borrower_in_p2p<CoinType>(): address acquires BorrowersInP2P {
        let heap_array = &borrow_global<BorrowersInP2P<CoinType>>(@account).heap_array;
        *vector::borrow(heap_array, 0)
    }

    #[view]
    public fun get_head_borrower_on_pool<CoinType>(): address acquires BorrowersOnPool {
        let heap_array = &borrow_global<BorrowersOnPool<CoinType>>(@account).heap_array;
        *vector::borrow(heap_array, 0)
    }

    #[view] 
    public fun get_supply_balance<CoinType>(sender_addr: address): (u256, u256) acquires SupplyRecord {
        let supply_map = &borrow_global<SupplyRecord<CoinType>>(@account).supply_map;
        let supply_balance = simple_map::borrow<address, SupplyBalance>(supply_map, &sender_addr);
        (supply_balance.in_p2p, supply_balance.on_pool)
    }

    #[view] 
    public fun get_borrow_balance<CoinType>(sender_addr: address): (u256, u256) acquires BorrowRecord {
        let borrow_map = &borrow_global<BorrowRecord<CoinType>>(@account).borrow_map;
        let borrow_balance = simple_map::borrow<address, BorrowBalance>(borrow_map, &sender_addr);
        (borrow_balance.in_p2p, borrow_balance.on_pool)
    }

    #[view]
    public fun get_max_gas_for_matching<CoinType>(): (u64, u64, u64, u64) acquires MaxGasForMatching {
        let max_gas = borrow_global<MaxGasForMatching<CoinType>>(@account);
        (max_gas.supply, max_gas.borrow, max_gas.withdraw, max_gas.repay)
    }

    #[view]
    public fun get_delta<CoinType>(): (u256, u256, u256, u256) acquires Delta {
        let delta = borrow_global<Delta<CoinType>>(@account);
        (delta.p2p_supply_delta, delta.p2p_borrow_delta, delta.p2p_supply_amount, delta.p2p_borrow_amount)
    }
}
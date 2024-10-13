module account::utils {
    use coin_addr::aurita_coin::{USDC, USDT, WBTC, STAPT, APT, WETH, CAKE};
    use account::storage;
    use account::math;
    use std::vector;
    use std::debug::print;
    use std::string;
    use aptos_std::type_info::{TypeInfo, type_of};
    use account::mock_aries;
    use account::mock_echelon;
    use account::interest_rate_manager;

    const BASE_12: u256 = 1000000000000; // 10^12
    const TOKEN_UNIT: u256 = 1000000; // 10^18

    struct LiquidityData has key {
        total_collateral: u256,
        total_borrowable: u256,
        total_max_debt: u256,
        total_debt: u256
    }

    fun init_module(sender: &signer) {
        move_to(
            sender,
            LiquidityData {
                total_collateral: 0,
                total_borrowable: 0,
                total_max_debt: 0,
                total_debt: 0
            }
        );
    }
    
    public fun get_user_supply_balance<CoinType>(sender_addr: address): u256 {
        let (in_p2p, on_pool) = storage::get_supply_balance<CoinType>(sender_addr);
        let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();
        let total_supply = math::ray_mul(in_p2p, p2p_supply_index) + math::ray_mul(on_pool, pool_supply_index);
        total_supply
    }

    public fun get_user_borrow_balance<CoinType>(sender_addr: address): u256 {
        let (in_p2p, on_pool) = storage::get_borrow_balance<CoinType>(sender_addr);
        let (pool_supply_index, p2p_borrow_index) = storage::get_pool_index<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();
        let total_borrow = math::ray_mul(in_p2p, p2p_borrow_index) + math::ray_mul(on_pool, p2p_borrow_index);
        total_borrow
    }

    public fun calculate_collateral_value<CoinType>(
        user_addr: address, underlying_price: u256
    ): u256 {
        let collateral =
            get_user_supply_balance<CoinType>(user_addr) * underlying_price / TOKEN_UNIT;
        collateral
    }

    public fun calculate_debt_value<CoinType>(
        user_addr: address, underlying_price: u256
    ): u256 {
        let debt =
            get_user_borrow_balance<CoinType>(user_addr) * underlying_price
                / TOKEN_UNIT;
        debt
    }

    public fun get_asset_price<CoinType>(): u256 {
        let coin_type = type_of<CoinType>();
        let asset_price: u256 = 0;
        if (coin_type == type_of<USDT>() || coin_type == type_of<USDC>()) {
            asset_price = 1000000 * BASE_12;
        };

        if (coin_type == type_of<WBTC>()) {
            asset_price = 63559000000 * BASE_12;
        };

        if (coin_type == type_of<STAPT>()) {
            asset_price == 8640000 * BASE_12;
        };

        if (coin_type == type_of<APT>()) {
            asset_price == 7940000 * BASE_12;
        };

        if(coin_type == type_of<WETH>()) {
            asset_price == 2626000000 * BASE_12;
        };

        if(coin_type == type_of<CAKE>()) {
            asset_price == 2050000 * BASE_12;
        };

        asset_price
    }

    public fun get_liquidity_data<CoinType>(
        user_addr: address, amount_withdrawn: u256, amount_borrowed: u256, market_id: u64
    ): (u256, u256, u256, u256) acquires LiquidityData {
        let market_coin = type_of<CoinType>();
        calculate_liquidity_for_each_market<USDC>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        calculate_liquidity_for_each_market<USDT>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        calculate_liquidity_for_each_market<WBTC>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        calculate_liquidity_for_each_market<STAPT>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        calculate_liquidity_for_each_market<APT>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        calculate_liquidity_for_each_market<WETH>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        calculate_liquidity_for_each_market<CAKE>(
            user_addr, amount_withdrawn, amount_borrowed, market_coin, market_id
        );
        let liquidity_data = borrow_global<LiquidityData>(@account);
        let (
            total_collateral,
            total_borrowable,
            total_max_debt,
            total_debt
        ) = (
            liquidity_data.total_collateral,
            liquidity_data.total_borrowable,
            liquidity_data.total_max_debt,
            liquidity_data.total_debt
        );
        remove_liquidity_data();
        (
            total_collateral,
            total_borrowable,
            total_max_debt,
            total_debt
        )
    }

    fun remove_liquidity_data() acquires LiquidityData {
        let liquidity_data = borrow_global_mut<LiquidityData>(@account);
        liquidity_data.total_collateral = 0;
        liquidity_data.total_borrowable = 0;
        liquidity_data.total_max_debt = 0;
        liquidity_data.total_debt = 0;
    }

    public fun calculate_liquidity_for_each_market<CoinType>(
        user_addr: address,
        amount_withdrawn: u256,
        amount_borrowed: u256,
        market_coin: TypeInfo,
        market_id: u64,
    ) acquires LiquidityData {
        let underlying_price = get_asset_price<CoinType>();

        interest_rate_manager::update_indexes<CoinType>(market_id);

        let (ltv, liquidation_threshold) = {
            if (market_id == 0) {
                mock_aries::get_market_configuration()
            } else {
                mock_echelon::get_market_configuration()
            }
        };
        let debt = calculate_debt_value<CoinType>(user_addr, underlying_price);
        let collateral = calculate_collateral_value<CoinType>(user_addr, underlying_price);
        let borrowable = math::wad_mul(collateral, ltv);
        let max_debt = math::wad_mul(collateral, liquidation_threshold);
        // print(&string::utf8(b"collateral"));
        // print(&collateral);
        // print(&ltv);
        // print(&borrowable);
        // print(&debt);
        // 635590000000000000000000 635580 * 10^18 * 9 * 10^17 = 5720220 * 10^35 / 10^18 = 5720220 * 10^17
        // 900000000000000000

        if (market_coin == type_of<CoinType>() && amount_borrowed > 0) {
            debt = debt + amount_borrowed * underlying_price / TOKEN_UNIT;
        };

        if (market_coin == type_of<CoinType>() && amount_withdrawn > 0) {
            let withdrawn = amount_withdrawn * underlying_price / TOKEN_UNIT;
            collateral = collateral - withdrawn;
            max_debt = max_debt - math::wad_mul(withdrawn, liquidation_threshold);
            borrowable = borrowable - math::wad_mul(withdrawn, ltv);
        };
    
        let liquidity_data = borrow_global_mut<LiquidityData>(@account);
        liquidity_data.total_collateral = liquidity_data.total_collateral + collateral;
        liquidity_data.total_borrowable = liquidity_data.total_borrowable + borrowable;
        liquidity_data.total_max_debt = liquidity_data.total_max_debt + max_debt;
        liquidity_data.total_debt = liquidity_data.total_debt + debt;
    }

    #[test_only]
    public fun init_module_for_tests(sender: &signer) {
        init_module(sender);
    }
}

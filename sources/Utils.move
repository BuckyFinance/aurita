module account::Utils {
    use account::coin::{USDC, USDT, WBTC, STAPT};
    use account::Storage;
    use std::vector;
    use aptos_std::type_info::{TypeInfo, type_of};
    use account::mock_lending;
    
    const BASE_12: u256 = 1000000000000; // 10^12
    const TOKEN_UNIT: u256 = 1000000000000000000; // 10^18

    struct LiquidityData has key {
        total_collateral_apt: u256,
        total_borrowable_apt: u256,
        total_max_debt_apt: u256,
        total_debt_apt: u256,
    }

    fun init_module(sender: &signer) {
        move_to(sender, LiquidityData{
            total_collateral_apt: 0,
            total_borrowable_apt: 0,
            total_max_debt_apt: 0,
            total_debt_apt: 0,
        });
    }

    public fun get_user_supply_balance<CoinType>(user_addr: address): u256 {
        let (in_p2p, on_pool) = Storage::get_supply_balance<CoinType>(user_addr);
        let total_supply = in_p2p + on_pool;
        total_supply
    }

    public fun get_user_borrow_balance<CoinType>(user_addr: address): u256 {
        let (in_p2p, on_pool) = Storage::get_borrow_balance<CoinType>(user_addr);
        let total_borrow = in_p2p + on_pool;
        total_borrow
    }

    public fun calculate_collateral_value<CoinType>(
        user_addr: address, 
        underlying_price: u256): u256
    {
        let collateral = get_user_supply_balance<CoinType>(user_addr) * underlying_price / TOKEN_UNIT;
        collateral
    }

    public fun calculate_debt_value<CoinType>(
        user_addr: address,
        underlying_price: u256): u256
    {
        let debt = get_user_borrow_balance<CoinType>(user_addr) * underlying_price / TOKEN_UNIT;
        debt
    }

    public fun get_asset_price<CoinType>(): u256 {
        let coin_type = type_of<CoinType>();
        let asset_price: u256 = 0;
        if(coin_type == type_of<USDT>() || coin_type == type_of<USDC>()) {
            asset_price = 1 * BASE_12;
        };

        if(coin_type == type_of<WBTC>()) {
            asset_price = 60000000000 * BASE_12;
        };

        if(coin_type == type_of<STAPT>()) {
            asset_price == 6270000 * BASE_12;
        };

        asset_price
    }

    public fun get_liquidity_data<CoinType>(
        user_addr: address, 
        amount_withdrawn: u256,
        amount_borrowed: u256,
    ): (u256, u256, u256, u256) acquires LiquidityData {
        let market_coin = type_of<CoinType>();
        calculate_liquidity_for_each_market<USDC>(user_addr, amount_withdrawn, amount_borrowed, market_coin);
        calculate_liquidity_for_each_market<USDT>(user_addr, amount_withdrawn, amount_borrowed, market_coin);
        calculate_liquidity_for_each_market<WBTC>(user_addr, amount_withdrawn, amount_borrowed, market_coin);
        calculate_liquidity_for_each_market<STAPT>(user_addr, amount_withdrawn, amount_borrowed, market_coin);
        let liquidity_data = borrow_global<LiquidityData>(@account);
        (liquidity_data.total_collateral_apt, liquidity_data.total_borrowable_apt, liquidity_data.total_max_debt_apt, liquidity_data.total_debt_apt)
    }

    public fun calculate_liquidity_for_each_market<CoinType>(
        user_addr: address,
        amount_withdrawn: u256,
        amount_borrowed: u256,
        market_coin: TypeInfo
    ) acquires LiquidityData {
        let underlying_price = get_asset_price<CoinType>();

        // @todo: update index when implemented interest rate manager
        
        let (ltv, liquidation_threshold) = mock_lending::get_market_configuration();
        let debt_apt = calculate_debt_value<CoinType>(user_addr, underlying_price);
        let collateral_apt = calculate_collateral_value<CoinType>(user_addr, underlying_price);
        let borrowable_apt = collateral_apt * ltv;
        let max_debt_apt = collateral_apt * liquidation_threshold;

        if(market_coin == type_of<CoinType>() && amount_borrowed > 0) {
            debt_apt = debt_apt + amount_borrowed * underlying_price / TOKEN_UNIT;
        };

        if(market_coin == type_of<CoinType>() && amount_withdrawn > 0) {
            let withdrawn = amount_withdrawn * underlying_price / TOKEN_UNIT;
            collateral_apt = collateral_apt - withdrawn;
            max_debt_apt = max_debt_apt - withdrawn * liquidation_threshold;
            borrowable_apt = borrowable_apt - withdrawn * ltv;
        };
        let liquidity_data = borrow_global_mut<LiquidityData>(@account);
        liquidity_data.total_collateral_apt = liquidity_data.total_collateral_apt + collateral_apt;
        liquidity_data.total_borrowable_apt = liquidity_data.total_borrowable_apt + borrowable_apt;
        liquidity_data.total_max_debt_apt = liquidity_data.total_max_debt_apt + max_debt_apt;
        liquidity_data.total_debt_apt = liquidity_data.total_debt_apt + debt_apt;
    }

}
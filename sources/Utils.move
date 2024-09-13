module account::Utils {
    use account::coin::{USDC, USDT, WBTC, STAPT};
    use account::Storage;
    use aptos_std::type_info::{TypeInfo, type_of};
    
    const BASE_12: u256 = 1000000000000;

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
        underlying_price: u256, 
        token_unit: u256): u256
    {
        let collateral = get_user_supply_balance<CoinType>(user_addr) * underlying_price / token_unit;
        collateral
    }

    public fun calculate_debt_value<CoinType>(
        user_addr: address,
        underlying_price: u256,
        token_unit: u256): u256
    {
        let debt = get_user_borrow_balance<CoinType>(user_addr) * underlying_price / token_unit;
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

}
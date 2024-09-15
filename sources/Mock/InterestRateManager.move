module account::Interest_rate_manager {
    use account::mock_lending;
    use account::Storage;
    use std::timestamp;

    public fun updateIndexes<CoinType>() {
        let pool_supply_index: u128 = mock_lending::get_pool_supply_index<CoinType>();
        let pool_borrow_index: u128 = mock_lending::get_pool_borrow_index<CoinType>();
        Storage::set_index<CoinType>(timestamp::now_seconds(), pool_supply_index, pool_borrow_index);
    }

}
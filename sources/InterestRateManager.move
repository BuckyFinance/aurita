module account::interest_rate_manager {
    use account::mock_lending;
    use account::storage;
    use std::timestamp;
    use std::debug::print;

    public fun update_indexes<CoinType>() {
        let pool_supply_index: u256 = mock_lending::get_pool_supply_index<CoinType>();
        let pool_borrow_index: u256 = mock_lending::get_pool_borrow_index<CoinType>();
        storage::set_index<CoinType>(
            timestamp::now_seconds(), pool_supply_index, pool_borrow_index
        );
    }
}

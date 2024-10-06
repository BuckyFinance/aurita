module account::interest_rate_manager {
    use account::mock_aries;
    use account::mock_echelon;
    use account::storage;
    use std::timestamp;
    use std::debug::print;

    public fun update_indexes<CoinType>(market_id: u64) {
        let pool_supply_index = {
            if(market_id == 0) {
                mock_aries::get_pool_supply_index<CoinType>()
            } else {
                mock_echelon::get_pool_supply_index<CoinType>()
            }
        };
        let pool_borrow_index = {
            if(market_id == 0) {
                mock_aries::get_pool_borrow_index<CoinType>()
            } else {
                mock_echelon::get_pool_borrow_index<CoinType>()
            }
        };
        storage::set_index<CoinType>(
            timestamp::now_seconds(), pool_supply_index, pool_borrow_index
        );
    }
}

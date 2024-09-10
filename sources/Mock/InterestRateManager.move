module account::Interest_rate_manager {
    use account::mock_lending;
    use account::Storage;
    use std::timestamp;

    public fun updateIndexes<CoinType>() {
        let poolSupplyIndex: u128 = mock_lending::get_pool_supply_index<CoinType>();
        let poolBorrowIndex: u128 = mock_lending::get_pool_borrow_index<CoinType>();
        Storage::setIndex<CoinType>(timestamp::now_seconds(), poolSupplyIndex, poolBorrowIndex);
    }

}
module account::market_lens {
    use account::mock_lending;

    #[view]
    public fun get_deposit_apy<CoinType>(): u256 {
        let (deposit_apy, borrow_apy) = mock_lending::get_market_apy<CoinType>();
        deposit_apy
    }

    #[view]
    public fun get_borrow_apy<CoinType>(): u256 {
        let (deposit_apy, borrow_apy) = mock_lending::get_market_apy<CoinType>();
        borrow_apy
    }
}
module account::market_lens {
    use account::mock_aries;
    use account::mock_echelon;
    use account::utils;

    #[view]
    public fun get_market_liquidity<CoinType>(market_id: u64): u256 {
        if(market_id == 0) {
            mock_aries::get_total_deposit<CoinType>()
        } else {
            mock_echelon::get_total_deposit<CoinType>()
        }
    }

    #[view]
    public fun get_deposit_apy<CoinType>(market_id: u64): u256 {
        if(market_id == 0) {
            let (deposit_apy, borrow_apy) = mock_aries::get_market_apy<CoinType>();
            deposit_apy
        } else {
            let (deposit_apy, borrow_apy) = mock_echelon::get_market_apy<CoinType>();
            deposit_apy
        }
    }

    #[view]
    public fun get_borrow_apy<CoinType>(market_id: u64): u256 {
        if(market_id == 0) {
            let (deposit_apy, borrow_apy) = mock_aries::get_market_apy<CoinType>();
            borrow_apy
        } else {
            let (deposit_apy, borrow_apy) = mock_echelon::get_market_apy<CoinType>();
            borrow_apy
        }
    }

    #[view]
    public fun get_asset_price<CoinType>(): u256 {
        utils::get_asset_price<CoinType>()
    }
}
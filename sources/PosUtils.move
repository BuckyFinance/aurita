module account::pos_utils {
    use account::coin::{USDC, USDT, WBTC, STAPT};
    use account::mock_lending::{Self};

    public fun deposit<CoinType>(user: &signer, amount: u256) {
        mock_lending::deposit<CoinType>(user, amount);
    }

    public fun withdraw<CoinType>(user: &signer, amount: u256) {
        mock_lending::withdraw<CoinType>(user, amount);
    }

    public fun borrow<CoinType>(user: &signer, amount: u256) {
        mock_lending::borrow<CoinType>(user, amount);
    }
    
    public fun repay<CoinType>(user: &signer, amount: u256) {
        mock_lending::repay<CoinType>(user, amount);
    }
}
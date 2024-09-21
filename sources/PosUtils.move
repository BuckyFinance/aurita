module account::PosUtils {
    use account::coin::{USDC, USDT, WBTC, STAPT};
    use aptos_framework::coin::{Self, Coin};
    use account::mock_lending::{Self};

    public fun deposit<CoinType>(user: &signer, amount: u256) {
        mock_lending::deposit<CoinType>(user, amount);
    }

    public fun withdraw<CoinType>(user: &signer, amount: u256): Coin<CoinType> {
        let coin = mock_lending::withdraw<CoinType>(user, amount);
        coin
    }

    public fun borrow<CoinType>(user: &signer, amount: u256): Coin<CoinType> {
        let coin = mock_lending::borrow<CoinType>(user, amount);
        coin
    }
    
    public fun repay<CoinType>(user: &signer, amount: u256) {
        mock_lending::repay<CoinType>(user, amount);
    }
}
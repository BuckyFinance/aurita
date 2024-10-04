module account::pos_utils {
    use aptos_framework::coin::{Self, Coin};
    use account::mock_aries;
    use account::mock_echelon;

    public fun deposit<CoinType>(user: &signer, amount: u256, market_id: u64) {
        if(market_id == 0) {
            mock_aries::deposit<CoinType>(user, amount);
        } else {
            mock_echelon::deposit<CoinType>(user, amount);
        }
    }

    public fun withdraw<CoinType>(user: &signer, amount: u256, market_id: u64): Coin<CoinType> {
        let coin = {
            if(market_id == 0) {
                mock_aries::withdraw<CoinType>(user, amount)
            } else {
                mock_echelon::withdraw<CoinType>(user, amount)
            }
        };
        coin
    }

    public fun borrow<CoinType>(user: &signer, amount: u256, market_id: u64): Coin<CoinType> {
        let coin = {
            if(market_id == 0) {
                mock_aries::borrow<CoinType>(user, amount)
            } else {
                mock_echelon::borrow<CoinType>(user, amount)
            }
        };
        coin
    }

    public fun repay<CoinType>(user: &signer, amount: u256, market_id: u64) {
        if(market_id == 0) {
            mock_aries::repay<CoinType>(user, amount);
        } else {
            mock_echelon::repay<CoinType>(user, amount);
        };
    }
}

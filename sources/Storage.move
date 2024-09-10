module account::Storage {
    use std::signer;
    use std::timestamp;

    struct PoolIndex<phantom CoinType> has key {
        lastUpdateTimestamp: u64,
        poolSupplyIndex: u128,
        poolBorrowIndex: u128,
    }

    struct Market<phantom CoinType> has key {
        reserveFactor: u16,
        p2pCursor: u16,
    }

    const ENOT_OWNER: u64 = 1;
    const EMARKET_EXIST: u64 = 2;
    const EMARKET_NOT_EXIST: u64 = 3;

    /// @ducanh2706 refactor later
    public fun create_market<CoinType>(owner: &signer, reserveFactor: u16, p2pCursor: u16) {
        assert!(signer::address_of(owner) == @account, ENOT_OWNER);
        assert!(!exists<Market<CoinType>>(@account), EMARKET_EXIST);
        
        move_to(owner, Market<CoinType> {
            reserveFactor,
            p2pCursor,
        });

        /// @ducanh2706 have to fix later (get index by calling pool)
        move_to(owner, PoolIndex<CoinType> {
            lastUpdateTimestamp: timestamp::now_seconds(), 
            poolSupplyIndex: 1000000000000000000,
            poolBorrowIndex: 1000000000000000000,
        });
    }

    public fun setPoolIndex<CoinType>(lastUpdateTimestamp: u64, poolSupplyIndex: u128, poolBorrowIndex: u128) acquires PoolIndex {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let poolIndex = borrow_global_mut<PoolIndex<CoinType>>(@account);
        poolIndex.lastUpdateTimestamp = lastUpdateTimestamp;
        poolIndex.poolSupplyIndex = poolSupplyIndex;
        poolIndex.poolBorrowIndex = poolBorrowIndex;
    }

    #[view]
    public fun getPoolIndex<CoinType>(): (u64, u128, u128) acquires PoolIndex {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let poolIndex = borrow_global<PoolIndex<CoinType>>(@account);
        (poolIndex.lastUpdateTimestamp, poolIndex.poolSupplyIndex, poolIndex.poolBorrowIndex)
    }

    #[view]
    public fun getMarket<CoinType>(): (u16, u16) acquires Market {
        assert!(exists<Market<CoinType>>(@account), EMARKET_NOT_EXIST);
        let market = borrow_global<Market<CoinType>>(@account);
        (market.reserveFactor, market.p2pCursor)
    }
}
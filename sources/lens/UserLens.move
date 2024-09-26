module account::user_lens {
    use account::storage;

    #[view]
    public fun get_total_supply<CoinType>(sender_addr: address): u256 {
        let (in_p2p, on_pool) = storage::get_supply_balance<CoinType>(sender_addr);
        let total_supply = in_p2p + on_pool;
        total_supply
    }

    #[view]
    public fun get_total_borrow<CoinType>(sender_addr: address): u256 {
        let (in_p2p, on_pool) = storage::get_borrow_balance<CoinType>(sender_addr);
        let total_borrow = in_p2p + on_pool;
        total_borrow
    }
}
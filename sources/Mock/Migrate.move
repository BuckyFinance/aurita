module account::migrate {
    use account::aurita_coin;
    use std::signer;
    use std::string;
    use account::entry_positions_manager;

    public entry fun migrate_aries<CoinType>(user: &signer, amount: u256) {
        aurita_coin::mint<CoinType>(user, (amount as u64));
        entry_positions_manager::supply<CoinType>(user, signer::address_of(user), amount, 100, 0);
    }

    public entry fun migrate_echelon<CoinType>(user: &signer, amount: u256) {
        aurita_coin::mint<CoinType>(user, (amount as u64));
        entry_positions_manager::supply<CoinType>(user, signer::address_of(user), amount, 100, 1);
    }
}
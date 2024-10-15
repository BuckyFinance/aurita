module account::migrate {
    use aptos_framework::coin::{Self, Coin};
    use std::signer;
    use std::string;
    use account::entry_positions_manager;
    use account::mock_aries;
    use account::mock_echelon;

    public entry fun migrate_from_aries<CoinType>(user: &signer, amount: u256) {
        let coin = mock_aries::user_withdraw<CoinType>(user, amount);
        coin::deposit<CoinType>(signer::address_of(user), coin);
        entry_positions_manager::supply<CoinType>(user, signer::address_of(user), amount, 100, 0);
    }

    public entry fun migrate_from_echelon<CoinType>(user: &signer, amount: u256) {
        let coin = mock_echelon::user_withdraw<CoinType>(user, amount);
        coin::deposit<CoinType>(signer::address_of(user), coin);
        entry_positions_manager::supply<CoinType>(user, signer::address_of(user), amount, 100, 0);
    }

    public entry fun migrate_to_aries<CoinType>(user: &signer, amount: u256) {
        let coin = mock_echelon::user_withdraw<CoinType>(user, amount);
        coin::deposit<CoinType>(signer::address_of(user), coin);
        mock_aries::user_deposit<CoinType>(user, amount);
    }

    public entry fun migrate_to_echelon<CoinType>(user: &signer, amount: u256) {
        let coin = mock_aries::user_withdraw<CoinType>(user, amount);
        coin::deposit<CoinType>(signer::address_of(user), coin);
        mock_echelon::user_deposit<CoinType>(user, amount);
    }
}
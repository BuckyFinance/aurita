module account::migrate {
    use account::coin::{CoinCapabiltity, USDC, USDT, WBTC};
    use std::signer;
    use std::string;
    use aptos_framework::coin::{BurnCapability, MintCapability};
    use aptos_framework::account;
    use account::mock_lending;
    use account::entry_positions_manager;

    public entry fun migrate<CoinType>(user: &signer, amount: u256) {
        coin::mint<CoinType>(signer::address_of(user), amount);
        entry_positions_manager::supply<CoinType>(user, signer::address_of(user), amount, 100);
    }
}
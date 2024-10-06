module account::user_lens {
    use account::storage;
    use account::utils;
    use account::math;
    use account::mock_aries;
    use account::mock_echelon;
    use account::coin::{USDC, USDT, WBTC, STAPT, APT, WETH, CAKE};
    use std::vector;
    use std::debug::print;
    use std::string;
    use aptos_std::type_info::{TypeInfo, type_of};

    #[view]
    public fun get_supply_positions(sender_addr: address): vector<TypeInfo> {
        storage::get_supply_positions(sender_addr)
    }

    #[view]
    public fun get_borrow_positions(sender_addr: address): vector<TypeInfo> {
        storage::get_borrow_positions(sender_addr)
    }

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

    #[view]
    public fun get_health_factor(sender_addr: address, market_id: u64): u256 {
        let all_positions_created = storage::get_all_postions_created(sender_addr);
        let i = 0;
        let positions_number = vector::length(&all_positions_created);
        let user_total_max_debt = 0;
        let user_total_debt = 0;
        let (ltv, liquidation_threshold) = {
            if(market_id == 0) {
                mock_aries::get_market_configuration()
            } else {
                mock_echelon::get_market_configuration()
            }
        };
        while(i < positions_number) {
            let coin_type = vector::borrow(&all_positions_created, (i as u64));
            let (collateral, debt) = get_liquidity_data(sender_addr, *coin_type , market_id);
            user_total_max_debt = user_total_max_debt + math::ray_mul(
                collateral, liquidation_threshold
            );
            user_total_debt = user_total_debt + debt;
            // print(&debt);
            i = i + 1;
        };

        let health_factor = storage::max_u256();
        // print(&user_total_max_debt);
        // print(&user_total_debt);
        if(user_total_debt > 0) {
            health_factor = user_total_max_debt / user_total_debt;
        };
        health_factor
    }

    #[view]
    public fun get_user_supply_apy<CoinType>(market_id: u64): u256 {
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();
        let (deposit_apy, borrow_apy) = {
            if(market_id == 0) {
                mock_aries::get_market_apy<CoinType>()
            } else {
                mock_echelon::get_market_apy<CoinType>()
            }
        };
        let p2p_supply_apy = deposit_apy * p2p_supply_index / 1000000000000000000;
        p2p_supply_apy
    }

    #[view]
    public fun get_user_borrow_apy<CoinType>(market_id: u64): u256 {
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();
        let (deposit_apy, borrow_apy) = {
            if(market_id == 0) {
                mock_aries::get_market_apy<CoinType>()
            } else {
                mock_echelon::get_market_apy<CoinType>()
            }
        };
        let p2p_borrow_apy = borrow_apy * p2p_borrow_index / 1000000000000000000;
        p2p_borrow_apy
    }

    fun get_user_supply_balance(sender_addr: address, coin_type: TypeInfo): u256 {
        if(coin_type == type_of<USDC>()) {
            utils::get_user_supply_balance<USDC>(sender_addr)
        } else if(coin_type == type_of<USDT>()) {
            utils::get_user_supply_balance<USDT>(sender_addr)
        } else if(coin_type == type_of<WBTC>()) {
            utils::get_user_supply_balance<WBTC>(sender_addr)
        } else if(coin_type == type_of<STAPT>()) {
            utils::get_user_supply_balance<STAPT>(sender_addr)
        } else if(coin_type == type_of<APT>()) {
            utils::get_user_supply_balance<APT>(sender_addr)
        } else if(coin_type == type_of<WETH>()) {
            utils::get_user_supply_balance<WETH>(sender_addr)
        } else if(coin_type == type_of<CAKE>()) {
            utils::get_user_supply_balance<CAKE>(sender_addr)
        } else {
            0
        }
    } 

    fun get_user_borrow_balance(sender_addr: address, coin_type: TypeInfo): u256 {
        if(coin_type == type_of<USDC>()) {
            utils::get_user_borrow_balance<USDC>(sender_addr)
        } else if(coin_type == type_of<USDT>()) {
            utils::get_user_borrow_balance<USDT>(sender_addr)
        } else if(coin_type == type_of<WBTC>()) {
            utils::get_user_borrow_balance<WBTC>(sender_addr)
        } else if(coin_type == type_of<STAPT>()) {
            utils::get_user_borrow_balance<STAPT>(sender_addr)
        } else if(coin_type == type_of<APT>()) {
            utils::get_user_borrow_balance<APT>(sender_addr)
        } else if(coin_type == type_of<WETH>()) {
            utils::get_user_borrow_balance<WETH>(sender_addr)
        } else if(coin_type == type_of<CAKE>()) {
            utils::get_user_borrow_balance<CAKE>(sender_addr)
        } else {
            0 as u256
        }
    } 

    fun get_underlying_price(coin_type: TypeInfo): u256 {
        if(coin_type == type_of<USDC>()) {
            utils::get_asset_price<USDC>()
        } else if(coin_type == type_of<USDT>()) {
            utils::get_asset_price<USDT>()
        } else if(coin_type == type_of<WBTC>()) {
            utils::get_asset_price<WBTC>()
        } else if(coin_type == type_of<STAPT>()) {
            utils::get_asset_price<STAPT>()
        } else if(coin_type == type_of<APT>()) {
            utils::get_asset_price<APT>()
        } else if(coin_type == type_of<WETH>()) {
            utils::get_asset_price<WETH>()
        } else if(coin_type == type_of<CAKE>()) {
            utils::get_asset_price<CAKE>()
        } else {
            0
        }
    }

    // need to fix coin type when borrow
    fun get_liquidity_data(sender_addr: address, coin_type: TypeInfo, market_id: u64): (u256, u256) {
        let user_supply_balance = get_user_supply_balance(sender_addr, coin_type);
        let user_borrow_balance = get_user_borrow_balance(sender_addr, coin_type);
        let underlying_price = get_underlying_price(coin_type);
        // print(&user_borrow_balance);
        let debt = user_borrow_balance * underlying_price;
        let collateral = user_supply_balance * underlying_price;
        (collateral, debt)
    }

}
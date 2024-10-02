module account::entry_positions_manager {
    use std::signer;
    use std::debug::print;
    use account::storage;
    use account::interest_rate_manager;
    use account::math;
    use account::matching_engine;
    use account::pos_utils;
    use account::utils;
    use std::string;

    use std::coin::{Coin, Self};

    const EAMOUNT_ZERO: u64 = 1;
    const EBORROW_NOT_ALLOWED: u64 = 2;

    struct SupplyVar has copy, drop {
        remain_to_supply: u256,
        pool_borrow_index: u256,
        to_repay: u256
    }

    struct BorrowVar has copy, drop {
        remain_to_borrow: u256,
        pool_supply_index: u256,
        to_withdraw: u256
    }

    public fun supply<CoinType>(
        user: &signer,
        on_behalf: address,
        amount: u256,
        iterations: u256,
        market_id: u64,
    ) {
        let user_addr = signer::address_of(user);
        if(storage::is_position_open(user_addr) == false) {
            storage::open_position(user);
        };
        storage::add_supply_positions<CoinType>(user_addr);
        assert!(amount > 0, EAMOUNT_ZERO);

        let (reserveFactor, p2pCursor) = storage::get_market<CoinType>();

        interest_rate_manager::update_indexes<CoinType>(market_id);

        // get index
        let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();

        let vars: SupplyVar = SupplyVar {
            remain_to_supply: amount,
            pool_borrow_index: pool_borrow_index,
            to_repay: 0
        };

        let (p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount) =
            storage::get_delta<CoinType>();

        // match with delta
        if (p2p_borrow_delta > 0) {
            let matched_delta =
                math::min(
                    vars.remain_to_supply,
                    math::ray_mul(p2p_borrow_delta, vars.pool_borrow_index)
                );
            p2p_borrow_delta = p2p_borrow_delta
                - math::ray_div(matched_delta, vars.pool_borrow_index);
            vars.to_repay = matched_delta;
            vars.remain_to_supply = vars.remain_to_supply - matched_delta;
        };

        // match with borrower from pool (P2P)
        if (vars.remain_to_supply > 0) {
            let (matched_amount, remain_iterations) =
                matching_engine::match_borrower<CoinType>(
                    user, vars.remain_to_supply, iterations
                );
            vars.to_repay = vars.to_repay + matched_amount;
            vars.remain_to_supply = vars.remain_to_supply - matched_amount;
            p2p_borrow_amount = p2p_borrow_amount
                + math::ray_div(matched_amount, p2p_borrow_index);
        };

        let (user_supply_in_p2p, user_supply_on_pool) =
            storage::get_supply_balance<CoinType>(on_behalf);

        if (vars.to_repay > 0) {
            let to_add_in_p2p: u256 = math::ray_div(vars.to_repay, p2p_supply_index);
            p2p_supply_amount = p2p_supply_amount + to_add_in_p2p;
            user_supply_in_p2p = user_supply_in_p2p + to_add_in_p2p;

            pos_utils::repay<CoinType>(user, vars.to_repay, market_id);
        };

        // supply remaining on pool

        if (vars.remain_to_supply > 0) {
            user_supply_on_pool = user_supply_on_pool
                + math::ray_div(vars.remain_to_supply, pool_supply_index);
            pos_utils::deposit<CoinType>(user, vars.remain_to_supply, market_id);
        };

        // update user supply balance
        storage::update_supply_record<CoinType>(
            on_behalf, user_supply_in_p2p, user_supply_on_pool
        );
        // update delta
        storage::set_delta<CoinType>(
            p2p_supply_delta,
            p2p_borrow_delta,
            p2p_supply_amount,
            p2p_borrow_amount
        );
        // update in heap
        matching_engine::update_supplier_in_DS<CoinType>(on_behalf);
    }

    public fun borrow<CoinType>(
        user: &signer, amount: u256, iterations: u256, market_id: u64
    ) {
        let user_addr = signer::address_of(user);
        storage::add_borrow_positions<CoinType>(user_addr);
        assert!(amount > 0, EAMOUNT_ZERO);

        let (reserveFactor, p2pCursor) = storage::get_market<CoinType>();

        interest_rate_manager::update_indexes<CoinType>(market_id);

        assert!(borrow_allowed<CoinType>(user_addr, amount, market_id), EBORROW_NOT_ALLOWED);

        // get index
        let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();

        let (p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount) =
            storage::get_delta<CoinType>();
        let vars: BorrowVar = BorrowVar {
            remain_to_borrow: amount,
            pool_supply_index: pool_supply_index,
            to_withdraw: 0
        };

        // match with delta
        if (p2p_supply_delta > 0) {
            let matched_delta =
                math::min(
                    vars.remain_to_borrow,
                    math::ray_mul(p2p_supply_delta, vars.pool_supply_index)
                );
            p2p_supply_delta = p2p_supply_delta
                - math::ray_div(matched_delta, vars.pool_supply_index);

            vars.to_withdraw = matched_delta;
            vars.remain_to_borrow = vars.remain_to_borrow - matched_delta;
        };

        // match with supplier from pool (P2P)
        if (vars.remain_to_borrow > 0) {
            let (matched_amount, remain_iterations) =
                matching_engine::match_supplier<CoinType>(
                    user, vars.remain_to_borrow, iterations
                );
            vars.to_withdraw = vars.to_withdraw + matched_amount;
            vars.remain_to_borrow = vars.remain_to_borrow - matched_amount;
            p2p_supply_amount = p2p_supply_amount
                + math::ray_div(matched_amount, p2p_supply_index);

        };

        let (user_borrow_in_p2p, user_borrow_on_pool) =
            storage::get_borrow_balance<CoinType>(user_addr);

        let withdraw_coin: Coin<CoinType> = coin::zero<CoinType>();
        if (vars.to_withdraw > 0) {
            let to_add_in_p2p = math::ray_div(vars.to_withdraw, p2p_borrow_index);
            p2p_borrow_amount = p2p_borrow_amount + to_add_in_p2p;
            user_borrow_in_p2p = user_borrow_in_p2p + to_add_in_p2p;

            coin::merge(
                &mut withdraw_coin, pos_utils::withdraw<CoinType>(user, vars.to_withdraw, market_id)
            );
        };

        // borrow remaining from pool
        if (vars.remain_to_borrow > 0) {
            user_borrow_on_pool = user_borrow_on_pool
                + math::ray_div(vars.remain_to_borrow, pool_borrow_index);
            coin::merge(
                &mut withdraw_coin,
                pos_utils::borrow<CoinType>(user, vars.remain_to_borrow, market_id)
            );
        };

        // update user borrow balance
        storage::update_borrow_record<CoinType>(
            user_addr, user_borrow_in_p2p, user_borrow_on_pool
        );

        // update delta
        storage::set_delta<CoinType>(
            p2p_supply_delta,
            p2p_borrow_delta,
            p2p_supply_amount,
            p2p_borrow_amount
        );
        // update in heap
        matching_engine::update_borrower_in_DS<CoinType>(user_addr);

        // transfer token to user
        coin::deposit(user_addr, withdraw_coin);
    }

    fun borrow_allowed<CoinType>(user: address, borrow_amount: u256, market_id: u64): bool {
        let (total_collateral, total_borrowable, total_max_debt, total_debt) =
            utils::get_liquidity_data<CoinType>(user, 0, borrow_amount, market_id);
        (total_debt <= total_borrowable)
    }
}

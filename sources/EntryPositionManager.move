module account::entry_positions_manager {
    use std::signer;
    use account::storage;
    use account::interest_rate_manager;
    use account::math;
    use account::matching_engine;
    use account::pos_utils;

    const EAMOUNT_ZERO: u64 = 1;

    struct SupplyVar has copy, drop {
        remain_to_supply: u256,
        pool_borrow_index: u256,
        to_repay: u256,
    }

    public fun supply<CoinType>(user: &signer, on_behalf: address, amount: u256, iterations: u256) {
        let user_addr = signer::address_of(user);
        assert!(amount > 0, EAMOUNT_ZERO);

        let (reserveFactor, p2pCursor) = storage::get_market<CoinType>();

        interest_rate_manager::update_indexes<CoinType>();

        // get index
        let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();

        let vars: SupplyVar = SupplyVar {
            remain_to_supply: amount,
            pool_borrow_index: pool_borrow_index,
            to_repay: 0,
        };

        let (p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount) = storage::get_delta<CoinType>();

        // match with delta
        if (p2p_borrow_delta > 0) {
            let matched_delta = math::min(vars.remain_to_supply, math::ray_mul(p2p_borrow_delta, vars.pool_borrow_index));
            p2p_borrow_delta = p2p_borrow_delta - math::ray_div(matched_delta, vars.pool_borrow_index);
            vars.to_repay = matched_delta;
            vars.remain_to_supply = vars.remain_to_supply - matched_delta;
        };


        // match with borrower from pool (P2P)
        if (vars.remain_to_supply > 0) {
            let (matched_amount, remain_iterations) = matching_engine::match_borrower<CoinType>(user, vars.remain_to_supply, iterations);
            vars.to_repay = vars.to_repay + matched_amount;
            vars.remain_to_supply = vars.remain_to_supply - matched_amount;
            p2p_borrow_amount = p2p_borrow_amount + math::ray_div(matched_amount, p2p_borrow_index);
        };

        let (user_supply_in_p2p, user_supply_on_pool) = storage::get_supply_balance<CoinType>(on_behalf);

        if (vars.to_repay > 0) {
            let to_add_in_p2p: u256 = math::ray_div(vars.to_repay, p2p_supply_index);
            p2p_supply_amount = p2p_supply_amount + to_add_in_p2p;
            user_supply_in_p2p = user_supply_in_p2p + to_add_in_p2p;

            pos_utils::repay<CoinType>(user, vars.to_repay);
        };

        // supply remaining on pool

        if (vars.remain_to_supply > 0) {
            user_supply_on_pool = user_supply_on_pool + math::ray_div(vars.remain_to_supply, pool_supply_index);
            pos_utils::deposit<CoinType>(user, vars.remain_to_supply);
        };

        matching_engine::update_supplier_in_DS<CoinType>(on_behalf);

        // update user supply balance
        storage::update_supply_record<CoinType>(on_behalf, user_supply_in_p2p, user_supply_on_pool);
        // update delta
        storage::set_delta<CoinType>(p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount);

    }
}
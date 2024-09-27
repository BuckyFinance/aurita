module account::exit_positions_manager {
    use std::signer;
    use account::utils;
    use account::math;
    use account::storage;
    use account::pos_utils;
    use aptos_framework::coin::{Self, Coin};
    use account::matching_engine;
    use account::interest_rate_manager;

    public entry fun withdraw<CoinType>(
        sender: &signer,
        amount: u256,
        receiver: address,
        max_iterations_for_matching: u256
    ) {
        let sender_addr = signer::address_of(sender);
        interest_rate_manager::update_indexes<CoinType>();
        let total_supply = utils::get_user_supply_balance<CoinType>(sender_addr);
        let to_withdraw = math::min(total_supply, amount);
        let is_withdraw_allowed = withdraw_allowed<CoinType>(sender_addr, to_withdraw);
        if (is_withdraw_allowed) {
            unsafe_withdraw_logic<CoinType>(
                sender,
                to_withdraw,
                receiver,
                max_iterations_for_matching
            );
        };
    }

    public entry fun repay<CoinType>(
        sender: &signer,
        on_behalf: address,
        amount: u256,
        max_iterations_for_matching: u256
    ) {
        let sender_addr = signer::address_of(sender);
        interest_rate_manager::update_indexes<CoinType>();
        let total_borrow = utils::get_user_borrow_balance<CoinType>(sender_addr);
        let to_repay = math::min(total_borrow, amount);
        unsafe_repay_logic<CoinType>(
            sender, on_behalf, to_repay, max_iterations_for_matching
        );
    }

    fun unsafe_withdraw_logic<CoinType>(
        sender: &signer,
        amount: u256,
        receiver: address,
        max_iteration: u256
    ) {
        let sender_addr = signer::address_of(sender);
        let remaining_to_withdraw = amount;
        let remaining_iterations_for_matching = max_iteration;
        let (supplier_balance_in_p2p, supplier_balance_on_pool) =
            storage::get_supply_balance<CoinType>(sender_addr);
        let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
        let to_withdraw = 0;

        // POOL WITHDRAW
        let on_pool_supply = supplier_balance_on_pool;
        if (on_pool_supply > 0) {
            let to_withdraw =
                math::min(
                    math::ray_mul(on_pool_supply, pool_supply_index),
                    remaining_to_withdraw
                );
            remaining_to_withdraw = remaining_to_withdraw - to_withdraw;
            supplier_balance_on_pool = supplier_balance_in_p2p
                - math::min(
                    on_pool_supply,
                    math::ray_div(to_withdraw, pool_supply_index)
                );
            if (remaining_to_withdraw == 0) {
                matching_engine::update_supplier_in_DS<CoinType>(sender_addr);

                // withdraw from pool
                let coin = pos_utils::withdraw<CoinType>(sender, to_withdraw);
                coin::deposit<CoinType>(signer::address_of(sender), coin);
                return;

            }
        };
        let (p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount) =
            storage::get_delta<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();
        let total_coin: Coin<CoinType> = coin::zero<CoinType>();

        supplier_balance_in_p2p = supplier_balance_in_p2p
            - math::min(
                supplier_balance_in_p2p,
                math::ray_div(remaining_to_withdraw, p2p_supply_index)
            );
        storage::update_supply_record<CoinType>(
            sender_addr, supplier_balance_in_p2p, supplier_balance_on_pool
        );
        matching_engine::update_supplier_in_DS<CoinType>(sender_addr);

        // reduce p2p supply delta
        if (remaining_to_withdraw > 0 && p2p_supply_delta > 0) {
            let matched_delta =
                math::min(
                    math::ray_mul(p2p_supply_delta, pool_supply_index),
                    remaining_to_withdraw
                );
            p2p_supply_delta = p2p_supply_delta
                - math::min(
                    p2p_supply_delta,
                    math::ray_div(remaining_to_withdraw, pool_supply_index)
                );
            p2p_supply_amount = p2p_supply_amount
                - math::ray_div(
                    matched_delta,
                    p2p_supply_index
                );
            to_withdraw = to_withdraw + matched_delta;
            remaining_to_withdraw = remaining_to_withdraw - matched_delta;
        };

        // P2P WITHDRAW
        // transfer withdraw -> promote supplier
        // if user matched p2p, other suppliers who matched p2p with current user should be rematched
        let head_supplier_on_pool = storage::get_head_supplier_on_pool<CoinType>();
        if (remaining_to_withdraw > 0 && head_supplier_on_pool != @0x0) {
            let (matched, iteration_consumed_in_matching) =
                matching_engine::match_supplier<CoinType>(
                    sender, remaining_to_withdraw, remaining_iterations_for_matching
                );
            if (remaining_iterations_for_matching <= iteration_consumed_in_matching) {
                remaining_iterations_for_matching = 0;
            } else {
                remaining_iterations_for_matching = remaining_iterations_for_matching
                    - iteration_consumed_in_matching;
            };

            remaining_to_withdraw = remaining_to_withdraw - matched;
            to_withdraw = to_withdraw + matched;
        };

        if (to_withdraw > 0) {
            let withdraw_coin = pos_utils::withdraw<CoinType>(sender, to_withdraw);
            coin::merge(&mut total_coin, withdraw_coin);
        };

        // breaking withdraw -> demote borrower
        if (remaining_to_withdraw > 0) {
            let (unmatched, iterations) =
                matching_engine::unmatch_borrower<CoinType>(
                    sender, remaining_to_withdraw, remaining_iterations_for_matching
                );
            if (unmatched < remaining_to_withdraw) {
                p2p_borrow_delta = p2p_borrow_delta
                    + math::ray_div(remaining_to_withdraw - unmatched, pool_borrow_index);
            };

            p2p_supply_amount = p2p_supply_amount
                - math::min(
                    p2p_supply_amount,
                    math::ray_div(remaining_to_withdraw, p2p_supply_index)
                );

            p2p_borrow_amount = p2p_borrow_amount
                - math::min(
                    p2p_borrow_amount,
                    math::ray_div(remaining_to_withdraw, p2p_borrow_index)
                );

            let borrow_coin = pos_utils::borrow<CoinType>(sender, remaining_to_withdraw);
            coin::merge(&mut total_coin, borrow_coin);
        };
        storage::set_delta<CoinType>(
            p2p_supply_delta,
            p2p_borrow_delta,
            p2p_supply_amount,
            p2p_borrow_amount
        );

        coin::deposit<CoinType>(signer::address_of(sender), total_coin);

    }

    fun unsafe_repay_logic<CoinType>(
        sender: &signer,
        on_behalf: address,
        amount: u256,
        max_iterations_for_matching: u256
    ) {
        let sender_addr = signer::address_of(sender);
        let remaining_to_repay = amount;
        let remaining_iterations_for_matching = max_iterations_for_matching;
        let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
        let (borrower_balance_in_p2p, borrower_balance_on_pool) =
            storage::get_borrow_balance<CoinType>(sender_addr);
        let to_repay = 0;

        // Pool Repay
        if (borrower_balance_on_pool > 0) {
            to_repay = math::min(
                math::ray_mul(borrower_balance_on_pool, pool_borrow_index),
                remaining_to_repay
            );
            remaining_to_repay = remaining_to_repay - to_repay;

            borrower_balance_on_pool = borrower_balance_on_pool
                - math::min(
                    borrower_balance_on_pool,
                    math::ray_div(to_repay, pool_borrow_index)
                );

            if (remaining_to_repay == 0) {
                matching_engine::update_borrower_in_DS<CoinType>(on_behalf);
                pos_utils::repay<CoinType>(sender, to_repay);
                return;
            }
        };

        let (p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount) =
            storage::get_delta<CoinType>();
        let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();
        borrower_balance_in_p2p = borrower_balance_in_p2p
            - math::min(
                borrower_balance_in_p2p,
                math::ray_div(remaining_to_repay, p2p_borrow_index)
            );

        storage::update_borrow_record<CoinType>(
            sender_addr, borrower_balance_in_p2p, borrower_balance_on_pool
        );
        matching_engine::update_borrower_in_DS<CoinType>(sender_addr);

        // reduce p2p borrow delta
        if (remaining_to_repay > 0 && p2p_borrow_delta > 0) {
            let matched_delta =
                math::min(
                    math::ray_mul(p2p_borrow_delta, pool_borrow_index),
                    remaining_to_repay
                );

            p2p_borrow_delta = p2p_borrow_delta
                - math::min(
                    p2p_borrow_delta,
                    math::ray_div(remaining_to_repay, pool_borrow_index)
                );

            p2p_borrow_amount = p2p_borrow_amount
                - math::ray_div(matched_delta, p2p_borrow_index);
            to_repay = to_repay + matched_delta;
            remaining_to_repay = remaining_to_repay - matched_delta;
        };

        // Repay the fee
        // Fee = (p2pBorrowAmount - p2pBorrowDelta) - (p2pSupplyAmount - p2pSupplyDelta).
        let fee_to_repay = 0;
        if (remaining_to_repay > 0) {
            let fee_borrow = math::ray_mul(p2p_borrow_amount, p2p_borrow_index);
            let fee_supply =
                math::ray_mul(p2p_supply_amount, p2p_supply_index)
                    - math::min(
                        math::ray_mul(p2p_supply_amount, p2p_supply_index),
                        math::ray_mul(p2p_supply_delta, pool_supply_index)
                    );
            fee_to_repay = fee_borrow - fee_supply;
            if (fee_to_repay > 0) {
                let fee_repaid = math::min(fee_to_repay, remaining_to_repay);
                remaining_to_repay = remaining_to_repay - fee_to_repay;
                p2p_borrow_amount = p2p_borrow_amount
                    - math::ray_div(
                        fee_repaid,
                        p2p_borrow_index
                    );
            }
        };

        // P2P REPAY
        // transfer repay -> promote borrowers
        let head_borrower_on_pool = storage::get_head_borrower_on_pool<CoinType>();
        if (remaining_to_repay > 0 && head_borrower_on_pool != @0x0) {
            let (matched, iteration_consumed_in_matching) =
                matching_engine::match_supplier<CoinType>(
                    sender, remaining_to_repay, remaining_iterations_for_matching
                );
            if (remaining_iterations_for_matching <= iteration_consumed_in_matching) {
                remaining_iterations_for_matching = 0;
            } else {
                remaining_iterations_for_matching = remaining_iterations_for_matching
                    - iteration_consumed_in_matching;
            };

            remaining_to_repay = remaining_to_repay - matched;
            to_repay = to_repay + matched;
        };

        pos_utils::repay<CoinType>(sender, to_repay);

        // breaking withdraw -> demote borrower
        if (remaining_to_repay > 0) {
            let (unmatched, iterations) =
                matching_engine::unmatch_supplier<CoinType>(
                    sender, remaining_to_repay, remaining_iterations_for_matching
                );
            if (unmatched < remaining_to_repay) {
                p2p_supply_delta = p2p_supply_delta
                    + math::ray_div(remaining_to_repay - unmatched, pool_supply_index);
            };

            p2p_supply_amount = p2p_supply_amount
                - math::min(
                    p2p_supply_amount,
                    math::ray_div(unmatched, p2p_supply_index)
                );

            p2p_borrow_amount = p2p_borrow_amount
                - math::min(
                    p2p_borrow_amount,
                    math::ray_div(unmatched, p2p_borrow_index)
                );

            pos_utils::deposit<CoinType>(sender, remaining_to_repay);
        };
        storage::set_delta<CoinType>(
            p2p_supply_delta,
            p2p_borrow_delta,
            p2p_supply_amount,
            p2p_borrow_amount
        );
    }

    // ============================== Helper Function =================================

    public fun get_user_health_factor<CoinType>(
        sender_addr: address, withdrawn_amount: u256
    ): u256 {
        let (total_collateral, total_borrowable, total_max_debt, total_debt) =
            utils::get_liquidity_data<CoinType>(sender_addr, withdrawn_amount, 0);
        let health_factor = storage::max_u256();
        if (total_debt > 0) {
            health_factor = total_max_debt / total_debt;
        };
        health_factor
    }

    fun withdraw_allowed<CoinType>(
        sender_addr: address, withdrawn_amount: u256
    ): bool {
        let health_factor =
            get_user_health_factor<CoinType>(sender_addr, withdrawn_amount);
        let is_withdraw_allowed =
            (health_factor >= storage::get_health_factor_liquidation_threshold());
        is_withdraw_allowed
    }
}

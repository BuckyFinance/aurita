module account::matching_engine {
    /*
    6 functions
    - Match supplier
    - Match borrower
    - Unmatch supplier
    - Unmatch borrower
    - update supplier in DS
    - update borrower in DS

    First implement match supplier and borrower, update supplier and update borrower in DS

    Use Utils, Storage contract
    */

    use account::storage;
    use account::utils;
    use std::debug::print;
    use account::math;

    struct MatchingVars has copy, drop {
        p2p_index: u256,
        to_match: u256,
        pool_index: u256,
    }

    struct UnmatchingVars has copy, drop {
        p2p_index: u256,
        to_unmatch: u256,
        pool_index: u256,
    }
    
    public fun match_supplier<CoinType>(user: &signer, amount: u256, max_iteration: u256): u256 {
        if (max_iteration == 0) {
            return 0;
        };

        let vars: MatchingVars = MatchingVars {
            p2p_index: 0,
            to_match: amount,
            pool_index: 0,
        };

        // get pool index and p2p index
        let (pool_index_supply, pool_index_borrow) = storage::get_pool_index<CoinType>();
        let (p2p_index_supply, p2p_index_borrow) = storage::get_p2p_index<CoinType>();

        vars.p2p_index = p2p_index_supply;
        vars.pool_index = pool_index_supply;

        let matched_supplier: address = storage::get_head_supplier_on_pool<CoinType>();
        let remaining_amount: u256 = amount;


        while (max_iteration > 0 && remaining_amount > 0 && matched_supplier != @0x0) {
            max_iteration = max_iteration - 1;

            let (p2p_supply_balance, pool_supply_balance) = storage::get_supply_balance<CoinType>(matched_supplier);

            vars.to_match = math::min(math::ray_mul(pool_supply_balance, vars.pool_index), remaining_amount);
            remaining_amount = remaining_amount - vars.to_match;

            pool_supply_balance = pool_supply_balance - math::ray_div(vars.to_match, vars.pool_index);
            p2p_supply_balance = p2p_supply_balance + math::ray_div(vars.to_match, vars.p2p_index);
        
            storage::update_supply_record<CoinType>(matched_supplier, p2p_supply_balance, pool_supply_balance);

            update_supplier_in_DS<CoinType>(matched_supplier, vars.to_match);

            matched_supplier = storage::get_head_supplier_on_pool<CoinType>();
        };

        amount - remaining_amount
    }

    public fun unmatch_supplier<CoinType>(user: &signer, amount: u256, max_iteration: u256): u256 {
        if (max_iteration == 0) {
            return 0;
        };

        let vars: UnmatchingVars = UnmatchingVars {
            p2p_index: 0,
            to_unmatch: amount,
            pool_index: 0,
        };

        // get pool index and p2p index
        let (pool_index_supply, pool_index_borrow) = storage::get_pool_index<CoinType>();
        let (p2p_index_supply, p2p_index_borrow) = storage::get_p2p_index<CoinType>();

        vars.p2p_index = p2p_index_supply;
        vars.pool_index = pool_index_supply;

        let matched_supplier: address = storage::get_head_supplier_in_p2p<CoinType>();
        let remaining_amount: u256 = amount;

        while (max_iteration > 0 && remaining_amount > 0 && matched_supplier != @0x0) {
            max_iteration = max_iteration - 1;

            let (p2p_supply_balance, pool_supply_balance) = storage::get_supply_balance<CoinType>(matched_supplier);

            vars.to_unmatch = math::min(math::ray_mul(p2p_supply_balance, vars.p2p_index), remaining_amount);
            remaining_amount = remaining_amount - vars.to_unmatch;

            pool_supply_balance = pool_supply_balance + math::ray_div(vars.to_unmatch, vars.pool_index);
            p2p_supply_balance = p2p_supply_balance - math::ray_div(vars.to_unmatch, vars.p2p_index);

            storage::update_supply_record<CoinType>(matched_supplier, p2p_supply_balance, pool_supply_balance);

            update_supplier_in_DS<CoinType>(matched_supplier, vars.to_unmatch);

            matched_supplier = storage::get_head_supplier_in_p2p<CoinType>();
        };

        amount - remaining_amount
    }

    public fun unmatch_borrower<CoinType>(user: &signer, amount: u256, max_iteration: u256): u256 {
        if (max_iteration == 0) {
            return 0;
        };

        let vars: UnmatchingVars = UnmatchingVars {
            p2p_index: 0,
            to_unmatch: amount,
            pool_index: 0,
        };

        // get pool index and p2p index
        let (pool_index_supply, pool_index_borrow) = storage::get_pool_index<CoinType>();
        let (p2p_index_supply, p2p_index_borrow) = storage::get_p2p_index<CoinType>();

        vars.p2p_index = p2p_index_borrow;
        vars.pool_index = pool_index_borrow;

        let matched_borrower: address = storage::get_head_borrower_in_p2p<CoinType>();

        let remaining_amount: u256 = amount;

        while (max_iteration > 0 && remaining_amount > 0 && matched_borrower != @0x0) {
            max_iteration = max_iteration - 1;

            let (p2p_borrow_balance, pool_borrow_balance) = storage::get_borrow_balance<CoinType>(matched_borrower);

            vars.to_unmatch = math::min(math::ray_mul(p2p_borrow_balance, vars.p2p_index), remaining_amount);
            remaining_amount = remaining_amount - vars.to_unmatch;

            pool_borrow_balance = pool_borrow_balance + math::ray_div(vars.to_unmatch, vars.pool_index);
            p2p_borrow_balance = p2p_borrow_balance - math::ray_div(vars.to_unmatch, vars.p2p_index);

            storage::update_borrow_record<CoinType>(matched_borrower, p2p_borrow_balance, pool_borrow_balance);

            update_borrower_in_DS<CoinType>(matched_borrower, vars.to_unmatch);

            matched_borrower = storage::get_head_borrower_in_p2p<CoinType>();
        };

        amount - remaining_amount
    }

    public fun match_borrower<CoinType>(user: &signer, amount: u256, max_iteration: u256) : u256 {
        if (max_iteration == 0) {
            return 0;
        };

        let vars: MatchingVars = MatchingVars {
            p2p_index: 0,
            to_match: amount,
            pool_index: 0,
        };
        
        // get pool index and p2p index
        let (pool_index_supply, pool_index_borrow) = storage::get_pool_index<CoinType>();
        let (p2p_index_supply, p2p_index_borrow) = storage::get_p2p_index<CoinType>();

        let matched_borrower = storage::get_head_borrower_on_pool<CoinType>();
        let remaining_amount = amount;

        vars.p2p_index = p2p_index_borrow;
        vars.pool_index = pool_index_borrow;

        while (max_iteration > 0 && remaining_amount > 0 && matched_borrower != @0x0) {
            max_iteration = max_iteration - 1;

            let (p2p_borrow_balance, pool_borrow_balance) = storage::get_borrow_balance<CoinType>(matched_borrower);

            vars.to_match = math::min(math::ray_mul(pool_borrow_balance, vars.pool_index), remaining_amount);
            remaining_amount = remaining_amount - vars.to_match;

            pool_borrow_balance = pool_borrow_balance - math::ray_div(vars.to_match, vars.pool_index);
            p2p_borrow_balance = p2p_borrow_balance + math::ray_div(vars.to_match, vars.p2p_index);

            storage::update_borrow_record<CoinType>(matched_borrower, p2p_borrow_balance, pool_borrow_balance);

            update_borrower_in_DS<CoinType>(matched_borrower, vars.to_match);

            matched_borrower = storage::get_head_borrower_on_pool<CoinType>();
        };

        amount - remaining_amount
    }

    // refactor later
    public fun update_supplier_in_DS<CoinType>(user: address, amount: u256) {
        // storage::remove_supplier_on_pool<CoinType>(user);
        // storage::add_supplier_on_pool<CoinType>(user);
    }

    // refactor later
    public fun update_borrower_in_DS<CoinType>(user: address, amount: u256) {
        // storage::remove_borrower_on_pool<CoinType>(user);
        // storage::add_borrower_on_pool<CoinType>(user);
    }
}
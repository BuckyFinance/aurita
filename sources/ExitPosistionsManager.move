// module account::exit_positions_manager {
//     use std::signer;
//     use account::utils;
//     use account::math;  
//     use account::storage;
//     use account::PosUtils;
//     use account::coin;

//     public fun withdraw_logic<CoinType>(
//         sender: &signer,
//         amount: u256,
//         receiver: address,
//         max_gas_for_matching: u256
//     ) {
//         let sender_addr = signer::address_of(sender);
//         // @todo: requires update index
//         let total_supply = utils::get_user_supply_balance<CoinType>(sender_addr);
//         let to_withdraw = math::min(total_supply, amount);
//         let is_withdraw_allowed = withdraw_allowed<CoinType>(sender_addr, to_withdraw);
//         if(is_withdraw_allowed) {
//             unsafe_withdraw_logic<CoinType>(sender, to_withdraw, receiver, max_gas_for_matching);
//         };
//     }

//     public fun repay_logic() {

//     }

//     fun unsafe_withdraw_logic<CoinType>(
//         sender: &signer, 
//         amount: u256,
//         receiver: address,
//         max_gas_for_matching: u256
//     ) {
//         let sender_addr = signer::address_of(sender);
//         let remaining_to_withdraw = amount;
//         let remaining_gas_for_matching = max_gas_for_matching;
//         let (supplier_balance_in_p2p, supplier_balance_on_pool) = storage::get_supply_balance<CoinType>(sender_addr);
//         let (pool_supply_index, pool_borrow_index) = storage::get_pool_index<CoinType>();
//         let to_withdraw = 0;
    
//         // POOL WITHDRAW
//         let on_pool_supply = supplier_balance_on_pool;
//         if(on_pool_supply > 0) {
//             let to_withdraw = math::min(
//                 math::ray_mul(on_pool_supply, pool_supply_index), 
//                 remaining_to_withdraw
//             );
//             remaining_to_withdraw = remaining_to_withdraw - to_withdraw;
//             supplier_balance_on_pool = supplier_balance_in_p2p - math::min(
//                 on_pool_supply,
//                 math::ray_div(to_withdraw, pool_supply_index),
//             );
//             if(remaining_to_withdraw == 0) {
//                 // @todo: update supplier in data structure
                
//                 // withdraw from pool
//                 PosUtils::withdraw<CoinType>(sender, to_withdraw); // @todo: sender must be this contract
//                 coin::mint<CoinType>(sender_addr, (to_withdraw as u64));
//                 return;

//             }
//         };
//         let (p2p_supply_delta, p2p_borrow_delta, p2p_supply_amount, p2p_borrow_amount) = storage::get_delta<CoinType>();
//         let (p2p_supply_index, p2p_borrow_index) = storage::get_p2p_index<CoinType>();

//         supplier_balance_in_p2p = supplier_balance_in_p2p - math::min(
//             supplier_balance_in_p2p,    
//             math::ray_div(remaining_to_withdraw, p2p_supply_index)
//         );
//         storage::update_supply_record<CoinType>(sender_addr, supplier_balance_in_p2p, supplier_balance_on_pool);    
//         // @todo: requires update supplier in data structure 

//         // reduce p2p supply delta
//         if(remaining_to_withdraw > 0 && p2p_supply_delta > 0) {
//             let matched_delta = math::min(
//                 math::ray_mul(p2p_supply_delta, pool_supply_index),
//                 remaining_to_withdraw,
//             );
//             p2p_supply_delta = p2p_supply_delta - math::min(
//                 p2p_supply_delta,
//                 math::ray_div(remaining_to_withdraw, pool_supply_index)
//             );
//             p2p_supply_amount = p2p_supply_amount - math::ray_div(
//                 matched_delta,
//                 p2p_supply_index
//             );
//             to_withdraw = to_withdraw + matched_delta;
//             remaining_to_withdraw = remaining_to_withdraw - matched_delta;
//         };

//         // P2P WITHDRAW
//         // transfer withdraw -> promote supplier
//         // if user matched p2p, other suppliers who matched p2p with current user should be rematched 
//         let head_supplier_on_pool = storage::get_head_supplier_on_pool<CoinType>();
//         if(remaining_to_withdraw > 0 && head_supplier_on_pool != @0x0) {
//             // @todo: rematch remaining supplier
//             // let (matched, gas_consumed_in_matching) = match_supplier(); 
//             if(remaining_gas_for_matching <= gas_consumed_in_matching) {
//                 remaining_gas_for_matching = 0;
//             } else {
//                 remaining_gas_for_matching = remaining_gas_for_matching - gas_consumed_in_matching;
//             };

//             remaining_to_withdraw = remaining_to_withdraw - matched;
//             to_withdraw = to_withdraw + matched;
//         };

//         if(to_withdraw > 0) {
//             PosUtils::withdraw<CoinType>(sender, to_withdraw);
//         };

//         // breaking withdraw -> demote borrower
//         if(remaining_to_withdraw > 0) {
//             // @todo: unmatched remaining supplier who not matched p2p to pool
//             // let unmatched = match_supplier(); 
//             if(unmatched < remaining_to_withdraw) {
                
//             }
//         }
//     }

//     fun unsafe_repay_logic() {

//     }

//     public fun get_user_health_factor<CoinType>(sender_addr: address, withdrawn_amount: u256): u256 {
//         let (total_collateral, total_borrowable, total_max_debt, total_debt) = utils::get_liquidity_data<CoinType>(sender_addr, withdrawn_amount, 0);
//         let health_factor = storage::max_u256();
//         if(total_debt > 0) {
//             health_factor = total_max_debt / total_debt;
//         };
//         health_factor
//     }

//     fun withdraw_allowed<CoinType>(sender_addr: address, withdrawn_amount: u256): bool {
//         let health_factor = get_user_health_factor<CoinType>(sender_addr, withdrawn_amount);
//         let is_withdraw_allowed = (health_factor >= storage::get_health_factor_liquidation_threshold());
//         is_withdraw_allowed
//     }

// }   
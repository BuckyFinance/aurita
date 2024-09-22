module account::heap_ds {
    use aptos_std::smart_vector::{SmartVector, Self};
    use aptos_std::smart_table::{SmartTable, Self};


    struct Account has store, drop, copy {
        user: address,
        value: u256,
    }

    struct HeapArray has store {
        accounts: SmartVector<Account>,
        sorted_size: u256,
        indexes: SmartTable<address, u256>,
    }

    const ROOT: u256 = 1;
    const EADDRESS_ZERO: u64 = 1;

    public fun create_new_heap(max_sorted: u256): HeapArray {
        HeapArray {
            accounts: smart_vector::new(),
            sorted_size: 0,
            indexes: smart_table::new(),
        }
    }

    public fun update(heap: &mut HeapArray, user: address, former_value: u256, new_value: u256, max_sorted: u256) {
        let size: u256 = heap.sorted_size;
        let new_size: u256 = compute_size(size, max_sorted);
        if (new_size != size) {
            heap.sorted_size = new_size;
        };

        if (former_value != new_value) {
            if (new_value == 0) {remove(heap, user, former_value);}
            else if (former_value == 0) {insert(heap, user, new_value, max_sorted);}
            else if (former_value < new_value) {increase(heap, user, new_value, max_sorted);}
            else {decrease(heap, user, new_value);};
        };
    }

    fun shift_up(heap: &mut HeapArray, index: u256) {
        let account_to_shift = get_account(heap, index);
        let value_to_shift = account_to_shift.value;
        let parent_account: Account = if (index > ROOT) get_account(heap, index / 2) else Account{user: @0x0, value: 0};
        while (index > ROOT && value_to_shift > parent_account.value) {
            set_account(heap, index, parent_account);
            index = index / 2;
            if (index > ROOT) parent_account = get_account(heap, index / 2);
        };
        set_account(heap, index, account_to_shift);
    }

    fun shift_down(heap: &mut HeapArray, index: u256) {
        let size: u256 = heap.sorted_size;
        let account_to_shift = get_account(heap, index);
        let value_to_shift = account_to_shift.value;
        let child_index: u256 = index * 2;

        while (child_index <= size) {
            let child_to_swap = get_account(heap, child_index);
            if (child_index < size) {
                let right_child = get_account(heap, child_index + 1);
                if (right_child.value > child_to_swap.value) {
                    child_to_swap = right_child;
                    child_index = child_index + 1;
                };
            };

            if (child_to_swap.value > value_to_shift) {
                set_account(heap, index, child_to_swap);
                index = child_index;
                child_index = index * 2;
            }
            else {
                break;
            };
        };
        set_account(heap, index, account_to_shift);
    }

    fun increase(heap: &mut HeapArray, user: address, value: u256, max_sorted: u256) {
        let index: u256 = *smart_table::borrow(&heap.indexes, user);
        set_account_value(heap, index, value);

        let next_size: u256 = heap.sorted_size + 1;

        if (index < next_size) {
            shift_up(heap, index);
        }
        else {
            swap(heap, index, next_size);
            shift_up(heap, next_size);
            heap.sorted_size = compute_size(next_size, max_sorted);
        }
    }

    fun decrease(heap: &mut HeapArray, user: address, value: u256) {
        let index: u256 = *smart_table::borrow(&heap.indexes, user);
        set_account_value(heap, index, value);
        if (index <= heap.sorted_size / 2) shift_down(heap, index);
    }

    fun remove(heap: &mut HeapArray, user: address, value: u256) {
        let index: u256 = *smart_table::borrow(&heap.indexes, user);
        let accounts_length: u256 = (smart_vector::length(&heap.accounts) as u256);

        // swap with the last account
        swap(heap, index, accounts_length);
        if (heap.sorted_size == accounts_length) heap.sorted_size = heap.sorted_size - 1;

        // remove the last account
        smart_vector::pop_back(&mut heap.accounts);
        // delele from map
        smart_table::remove(&mut heap.indexes, user);

        // swapped amount in the heap -> restore the invariant
        if (index <= heap.sorted_size) {
            if (value > get_account(heap, index).value) {
                shift_down(heap, index);
            }
            else {
                shift_up(heap, index);
            };
        }
    }

    fun insert(heap: &mut HeapArray, user: address, value: u256, max_sorted: u256) {
        assert!(user != @0x0, EADDRESS_ZERO);

        // push to the end of array
        smart_vector::push_back(&mut heap.accounts, Account{user: user, value: value});
        let accounts_length: u256 = (smart_vector::length(&heap.accounts) as u256);
        smart_table::upsert(&mut heap.indexes, user, accounts_length);

        // move to the end of heap, compute new heap
        let new_size: u256 = heap.sorted_size + 1;
        swap(heap, new_size, accounts_length);
        shift_up(heap, new_size);
        heap.sorted_size = compute_size(new_size, max_sorted);
    }

    fun swap(heap: &mut HeapArray, index1: u256, index2: u256) {
        if (index1 == index2) {
            return;
        };

        let old_account1 = get_account(heap, index1);
        let old_account2 = get_account(heap, index2);

        set_account(heap, index1, old_account2);
        set_account(heap, index2, old_account1);
    }

    fun set_account(heap: &mut HeapArray, index: u256, account: Account) {
        let old_account = smart_vector::borrow_mut(&mut heap.accounts, ((index - 1) as u64));
        *old_account = account;
    }

    fun set_account_value(heap: &mut HeapArray, index: u256, value: u256) {
        let old_account = smart_vector::borrow_mut(&mut heap.accounts, ((index - 1) as u64));
        old_account.value = value;
    }

    fun compute_size(size: u256, max_sorted: u256): u256 {
        while (size >= max_sorted) {
            size = size / 2;
        };
        size
    }

    public fun get_account(heap: &HeapArray, index: u256): Account {
        *smart_vector::borrow(&heap.accounts, ((index - 1) as u64))
    }

    public fun get_account_value(heap: &HeapArray, user: address): u256 {
        let index: u256 = *smart_table::borrow(&heap.indexes, user);
        get_account(heap, index).value
    }

    public fun get_head(heap: &HeapArray): address {
        if (smart_vector::length(&heap.accounts) == 0) {
            return @0x0;
        };
        get_account(heap, ROOT).user
    }

    public fun get_tail(heap: &HeapArray): address {
        if (smart_vector::length(&heap.accounts) == 0) {
            return @0x0;
        };
        get_account(heap, (smart_vector::length(&heap.accounts) as u256)).user
    }

    public fun get_prev(heap: &HeapArray, user: address): address {
        let index: u256 = *smart_table::borrow(&heap.indexes, user);
        if (index <= ROOT) {
            return @0x0;
        };
        get_account(heap, index - 1).user
    }

    public fun get_next(heap: &HeapArray, user: address): address {
        let index: u256 = *smart_table::borrow(&heap.indexes, user);
        if (index >= (smart_vector::length(&heap.accounts) as u256) || index == 0) {
            return @0x0;
        };
        get_account(heap, index + 1).user
    }

}
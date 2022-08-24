module 0x3::Vm {
    use std::signer;
    use std::vector;

    struct Account has key { balance: u128, code: vector<u8>, storage: vector<u8> }

    public fun init(account: &signer) {
        move_to(account, Account { balance: 0, code: vector::empty<u8>(), storage: vector::empty<u8>() });
    }

    public fun publish(account: &signer, code: vector<u8>) acquires Account {
        let c = &mut borrow_global_mut<Account>(signer::address_of(account)).code;
        *c = copy code;
    }

    public fun run(addr: address, calldata: vector<u8>): vector<u8> acquires Account {
        let code = borrow_global<Account>(addr).code;
        let pc: u64 = 0;

        // let caller: u128 = addr; // cannot do this
        let caller: u128 = 0x1234;

        let stack = vector::empty<u128>();
        let memory = vector::empty<u8>();
        let ret_data = vector::empty<u8>();

        while(pc < vector::length<u8>(&code)) {
            let op = *vector::borrow<u8>(&code, pc);
            
            // stop
            if (op == 0x00) {
                break
            };

            // add
            if (op == 0x01) {
                let lhs = vector::pop_back<u128>(&mut stack);
                let rhs = vector::pop_back<u128>(&mut stack);
                let result = lhs + rhs;
                vector::push_back<u128>(&mut stack, result);
                pc = pc + 1;
                continue
            };

            // mul
            if (op == 0x02) {
                let lhs = vector::pop_back<u128>(&mut stack);
                let rhs = vector::pop_back<u128>(&mut stack);
                let result = lhs * rhs;
                vector::push_back<u128>(&mut stack, result);
                pc = pc + 1;
                continue
            };

            // sub
            if (op == 0x03) {
                let lhs = vector::pop_back<u128>(&mut stack);
                let rhs = vector::pop_back<u128>(&mut stack);
                let result = lhs - rhs;
                vector::push_back<u128>(&mut stack, result);
                pc = pc + 1;
                continue
            };

            // div
            if (op == 0x03) {
                let lhs = vector::pop_back<u128>(&mut stack);
                let rhs = vector::pop_back<u128>(&mut stack);
                let result = lhs / rhs;
                vector::push_back<u128>(&mut stack, result);
                pc = pc + 1;
                continue
            };

            // pop
            if (op == 0x50) {
                let _ = vector::pop_back<u128>(&mut stack);
            };
            
            // push-n
            if (op >= 0x60 && op <= 0x6f) {
                let index = pc + 1 + (op as u64) - 0x60;
                let value = 0u128;
                let count = 0;
                while(index > pc) {
                    let byte = *vector::borrow<u8>(&code, index);
                    value = value + ((byte as u128)<<(8*count));
                    index = index - 1;
                    count = count + 1;
                };
                vector::push_back<u128>(&mut stack, value);
                pc = pc + 2 + (op as u64) - 0x60;
                continue
            };

            // caller
            if (op == 0x33) {
                vector::push_back(&mut stack, caller);
                pc = pc + 1;
                continue
            };
            
            // callvalue
            if (op == 0x34) {
                pc = pc + 1;
                continue
            };
            
            // calldataload
            if (op == 0x35) {
                pc = pc + 1;
                continue
            };
            
            // calldatasize
            if (op == 0x36) {
                let size = vector::length(&calldata);
                vector::push_back<u128>(&mut stack, (size as u128));
                pc = pc + 1;
                continue
            };
            
            // calldatacopy
            if (op == 0x37) {
                let dest_offset = vector::pop_back<u128>(&mut stack);
                let offset = vector::pop_back<u128>(&mut stack);
                let size = vector::pop_back<u128>(&mut stack);

                let dest_offset = (dest_offset as u64);
                let offset = (offset as u64);
                let size = (size as u64);
                
                // extends memory
                if(vector::length(&memory) > dest_offset + size) {
                    let new_chunk_length = vector::length(&memory) - (dest_offset + size);
                    let count = 0;
                    while(count < new_chunk_length) {
                        vector::push_back(&mut memory, 0u8);
                        count = count + 1;
                    };
                };

                // copy calldata elements to memory
                let index = 0;
                while(index < vector::length(&calldata) - offset && index < size) {
                    let value = *vector::borrow(&calldata, offset + index);
                    let dest = vector::borrow_mut(&mut memory, dest_offset + index);
                    *dest = value;
                    index = index + 1;
                };

                pc = pc + 1;
            };

            // returndatasize
            if (op == 0x3d) {
                let size = vector::length(&ret_data);
                vector::push_back(&mut stack, (size as u128));
                pc = pc + 1;
                continue
            };
            
            // mload
            if (op == 0x51) {
                pc = pc + 1;
                continue
            };

            // mstore
            if (op == 0x52) {
                pc = pc + 1;
                continue
            };

            // sload
            if (op == 0x54) {
                pc = pc + 1;
                continue
            };

            // sstore
            if (op == 0x55) {
                pc = pc + 1;
                continue
            };

            // jump
            if (op == 0x56) {
                pc = pc + 1;
                continue
            };

            // jumpi
            if (op == 0x57) {
                pc = pc + 1;
                continue
            };

            // msize
            if (op == 0x59) {
                let size = vector::length(&memory);
                vector::push_back<u128>(&mut stack, (size as u128));
                pc = pc + 1;
                continue
            };

            // jumpdest
            if (op == 0x5b) {
                pc = pc + 1;
                continue
            };

            // balance
            if (op == 0x31) {
                pc = pc + 1;
                continue
            };

            // call
            if (op == 0xf1) {
                pc = pc + 1;
                continue
            };

            // return
            if (op == 0xf3) {
                let ret = vector::empty<u8>();
                let top = vector::pop_back<u128>(&mut stack);
                let count = 0;
                while(count < 16) {
                    let byte = (top>>(8 * count)) & 0xff;
                    vector::push_back<u8>(&mut ret, (byte as u8));
                    count = count + 1;
                };
                vector::reverse(&mut ret);

                // temp
                let s = &mut borrow_global_mut<Account>(addr).storage;
                *s = copy ret;

                ret_data = copy ret;
                pc = pc + 1;
            };
        };

        return ret_data
    }

    public fun unpublish(account: &signer) acquires Account {
        let Account { balance: _, code: _, storage: _ } = move_from<Account>(signer::address_of(account));
    }
}
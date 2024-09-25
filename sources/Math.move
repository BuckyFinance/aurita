module account::math {
    const WAD: u256 = 1000000000000000000;
    const HALF_WAD: u256 = 1000000000000000000 / 2;
    const RAY: u256 = 1000000000000000000000000000;
    const HALF_RAY: u256 = 1000000000000000000000000000 / 2;
    const ERR_DIVSION_BY_ZERO: u64 = 1000;

    public fun wad_mul(a: u256, b: u256): u256 {
        if (a == 0 || b == 0) {
            return 0;
        };
        (a * b + HALF_WAD) / WAD
    }

    public fun wad_div(a: u256, b: u256): u256 {
        assert!(b != 0, ERR_DIVSION_BY_ZERO);
        let halfB = b / 2;
        (a * WAD + halfB) / b
    }

    public fun ray_mul(a: u256, b: u256): u256 {
        if (a == 0 || b == 0) {
            return 0;
        };
        (a * b + HALF_RAY) / RAY
    }

    public fun ray_div(a: u256, b: u256): u256 {
        assert!(b != 0, ERR_DIVSION_BY_ZERO);
        let halfB = b / 2;
        (a * RAY + halfB) / b
    }

    public fun min(a: u256, b: u256): u256 {
        if (a >= b) {
            return b;
        };
        a
    }

    public fun max(a: u256, b: u256): u256 {
        if (a >= b) {
            return a;
        };
        b
    }
}

script {
    use account::coin::{Self, USDT, USDC, WBTC, STAPT, APT, WETH, CAKE};
    use account::storage;
    use account::mock_aries;
    use account::mock_echelon;
    
    const INITIAL_COIN_MOCK_POOL: u256 = 1000000000000000000; // 10^12
    const INITIAL_COIN: u64 = 1000000000000000000; // 10^12
    
    fun initialize(admin: &signer) {
        // mint coin for admin and user
        coin::mint<USDT>(admin, INITIAL_COIN);
        coin::mint<USDC>(admin, INITIAL_COIN);
        coin::mint<WBTC>(admin, INITIAL_COIN);
        coin::mint<STAPT>(admin, INITIAL_COIN);
        coin::mint<APT>(admin, INITIAL_COIN);
        coin::mint<WETH>(admin, INITIAL_COIN);
        coin::mint<CAKE>(admin, INITIAL_COIN);

        // init pool for mock lending
        mock_aries::admin_add_pool<USDT>(admin);
        mock_aries::admin_add_pool<USDC>(admin);
        mock_aries::admin_add_pool<WBTC>(admin);
        mock_aries::admin_add_pool<STAPT>(admin);
        mock_aries::admin_add_pool<APT>(admin);
        mock_aries::admin_add_pool<WETH>(admin);
        mock_aries::admin_add_pool<CAKE>(admin);
        mock_aries::create_usdt_market<USDT>();
        mock_aries::create_usdc_market<USDC>();
        mock_aries::create_wbtc_market<WBTC>();
        mock_aries::create_stapt_market<STAPT>();
        mock_aries::create_apt_market<APT>();
        mock_aries::create_weth_market<WETH>();
        mock_aries::create_cake_market<CAKE>();
        mock_aries::deposit<USDT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<USDC>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<WBTC>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<STAPT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<APT>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<WETH>(admin, INITIAL_COIN_MOCK_POOL);
        mock_aries::deposit<CAKE>(admin, INITIAL_COIN_MOCK_POOL);

        // initialize storage
        storage::create_market<USDT>(admin, 0, 0);
        storage::create_market<USDC>(admin, 0, 0);
        storage::create_market<WBTC>(admin, 0, 0);
        storage::create_market<STAPT>(admin, 0, 0);
        storage::create_market<APT>(admin, 0, 0);
        storage::create_market<WETH>(admin, 0, 0);
        storage::create_market<CAKE>(admin, 0, 0);
    }
}
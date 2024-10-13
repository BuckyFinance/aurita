
import { Aptos, AptosConfig } from "@aptos-labs/ts-sdk";
import { Network } from "aptos";
const aptosConfig = new AptosConfig({ network: Network.TESTNET});
export const aptos = new Aptos(aptosConfig);
export const moduleAriesMarket = "0xf55e848e77a859764141c59d9c72664bd8e4adc048f6fc0e73df885a89ef2576";
export const moduleEchelonMarket = "0x58e4568f9411d6137bdcdf4663f4b107ea4157813fadeb2b1e14492c917d59c0";
//===================================================================================
//================================== User Lens ======================================
//===================================================================================

export async function getUserAllSupplyPositions(userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const payload = {
        function: `${moduleAddress}::user_lens::get_supply_positions`,
        functionArguments: [userAddress],
    };
    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

// async function f(){
//     await getUserAllSupplyPositions("0xfa86e77fffd89b9b35df378006904175a0fcdaa2dd7487bdab47168f7710f119", 0);
// }

// f();


export async function getUserAllBorrowPositions(userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const payload = {
        function: `${moduleAddress}::user_lens::get_borrow_positions`,
        functionArguments: [userAddress],
    };
    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getUserSupplyAmount(coinSymbol, userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::user_lens::get_user_supply`,
        typeArguments: [coin],
        functionArguments: [userAddress],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getUserBorrowAmount(coinSymbol, userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::user_lens::get_user_borrow`,
        typeArguments: [coin],
        functionArguments: [userAddress],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getUserHealthFactor(userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const payload = {
        function: `${moduleAddress}::user_lens::get_health_factor`,
        functionArguments: [userAddress, market_id],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getUserBorrowable(userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const payload = {
        function: `${moduleAddress}::user_lens::get_borrowable`,
        functionArguments: [userAddress, market_id],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}


export async function getUserSupplyAPY(coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::user_lens::get_user_p2p_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getUserBorrowAPY(coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::user_lens::get_user_p2p_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getUserBalance(userAddress, coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const payload = {
        function: `${moduleAddress}::user_lens::get_balance`,
        typeArguments: [coin],
        functionArguments: [userAddress],
    };
    
    let result;
    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

//===================================================================================
//================================== Market Lens ======================================
//===================================================================================


export async function getMarketDepositAPY(coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const payload = {
        function: `${moduleAddress}::market_lens::get_deposit_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    console.log(payload);

    let result;
    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getBorrowAPY(coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::market_lens::get_borrow_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getMarketLiquidity(coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::market_lens::get_market_liquidity`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        //console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}


export async function getAssetPrice(coinSymbol) {

    const coin = `${moduleAriesMarket}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAriesMarket}::market_lens::get_asset_price`,
        typeArguments: [coin],
        functionArguments: [],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        // console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getTotalSupply(market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const payload = {
        function: `${moduleAriesMarket}::market_lens::get_total_supply`,
        functionArguments: [],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        // console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function getTotalBorrow(market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const payload = {
        function: `${moduleAriesMarket}::market_lens::get_total_borrow`,
        functionArguments: [],
    };

    try {
        const result = (await aptos.view({ payload }))[0];
        // console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

// async function f(){
//     await getAssetPrice("WBTC");
// }

// f();


import { Aptos } from "@aptos-labs/ts-sdk";
export const aptos = new Aptos();
export const moduleAriesMarket = "0xd6e74f1e6d12931e46e492ee7ec858fdcd2bb5bb93899bf55282fbe5e99c29ca";
export const moduleEchelonMarket = "";
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
        console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

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
        console.log(result);
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
        function: `${moduleAddress}::user_lens::get_total_supply`,
        typeArguments: [coin],
        functionArguments: [userAddress],
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

export async function getUserBorrowAmount(coinSymbol, userAddress, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::user_lens::get_total_borrow`,
        typeArguments: [coin],
        functionArguments: [userAddress],
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
        console.log(result);
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
        function: `${moduleAddress}::user_lens::get_user_supply_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
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

export async function getUserBorrowAPY(coinSymbol, market_id) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }

    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;

    const payload = {
        function: `${moduleAddress}::user_lens::get_user_borrow_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
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

//===================================================================================
//================================== User Lens ======================================
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
        result = (await aptos.view({ payload }))[0]; 
        console.log(result);
    } catch (error) {
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
        console.log(result);
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
        console.log(result);
        return result;
    } catch(error) {
        console.log(error);
        return;
    }
}

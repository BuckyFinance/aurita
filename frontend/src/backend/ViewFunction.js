import { aptos } from "../App.js";
import { moduleAriesMarket } from "../App.js";
import { moduleEchelonMarket } from "../App.js";

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

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_total_supply`,
        functionArguments: [userAddress],
    };
    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_total_borrow`,
        functionArguments: [userAddress],
    };
    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_total_supply`,
        typeArguments: [coin],
        functionArguments: [userAddress],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_total_borrow`,
        typeArguments: [coin],
        functionArguments: [userAddress],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_health_factor`,
        functionArguments: [userAddress, market_id],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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

    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_user_supply_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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

    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::user_lens::get_user_borrow_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::market_lens::get_deposit_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::market_lens::get_borrow_apy`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
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
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::market_lens::get_market_liquidity`,
        typeArguments: [coin],
        functionArguments: [market_id],
    };

    try {
        const result = (await aptos.view({ payLoad }))[0];
        console.log(result);
        return result;
    } catch {
        console.log(error);
        return;
    }
}
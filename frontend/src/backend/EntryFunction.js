import { aptos } from "../App.js";
import { moduleAriesMarket } from "../App.js";
import { moduleEchelonMarket } from "../App.js";

export async function mintCoin(coinSymbol, userAddress, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const amount_in_wei = amount * 1000000;

    const payLoad = {
        data: {
            function: `${moduleAddress}::aurita_coin::mint`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}

/**
 * @param coinSymbol {USDC, USDT, WBTC, STAPT, APT, WETH, CAKE}
 * @param market_id 0 - Areis Market, 1 - Echeclon Market
 */
export async function supply(coinSymbol, userAddress, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const onBehalfAddress = userAddress;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;

    const payLoad = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::supply`,
            typeArguments: [coin],
            functionArguments: [onBehalfAddress, amount_in_wei, iterations, market_id],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function borrow(coinSymbol, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;

    const payLoad = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::borrow`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei, iterations, market_id],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function withdraw(coinSymbol, userAddress, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;
    const receiver = userAddress;

    const payLoad = {
        data: {
            function: `${moduleAddress}::exit_positions_manager::withdraw`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei, receiver, market_id, iterations],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function repay(coinSymbol, userAddress, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAddress}::aurita_coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;
    const onBehalfAddress = userAddress;

    const payLoad = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::borrow`,
            typeArguments: [coin],
            functionArguments: [onBehalfAddress, amount_in_wei, iterations, market_id],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}


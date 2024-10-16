import { aptos } from "../App.js";
import { moduleAriesMarket } from "../App.js";
import { moduleEchelonMarket } from "../App.js";
import { moduleAuritaCoin } from "../App.js";

export async function mintCoin(coinSymbol, userAddress, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const amount_in_wei = amount * 1000000;

    const payload = {
        data: {
            function: `${moduleAuritaCoin}::aurita_coin::mint`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
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
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const onBehalfAddress = userAddress;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;

    const payload = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::supply`,
            typeArguments: [coin],
            functionArguments: [onBehalfAddress, amount_in_wei, iterations, market_id],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
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
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;

    const payload = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::borrow`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei, iterations, market_id],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
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
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;
    const receiver = userAddress;

    const payload = {
        data: {
            function: `${moduleAddress}::exit_positions_manager::withdraw`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei, receiver, market_id, iterations],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
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
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;
    const onBehalfAddress = userAddress;

    const payload = {
        data: {
            function: `${moduleAddress}::exit_positions_manager::repay`,
            typeArguments: [coin],
            functionArguments: [onBehalfAddress, amount_in_wei, iterations, market_id],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}

// deposit to Aries or Echelon
export async function depositToMockLending(coinSymbol, amount, market_id, signAndSubmitTransaction) {
    let moduleAddress;
    let func;
    if(market_id === 0) {
        moduleAddress = moduleAriesMarket;
        func = `${moduleAddress}::mock_aries::user_deposit`
    } else {
        moduleAddress = moduleEchelonMarket;
        func = `${moduleAddress}::mock_echelon::user_deposit`
    }
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const amount_in_wei = amount * 1000000;

    const payload = {
        data: {
            function: func,
            typeArguments: [coin],
            functionArguments: [amount_in_wei],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}

export async function migrate(coinSymbol, amount, source_market_id, target_market_id, signAndSubmitTransaction) {
    console.log(coinSymbol, amount, source_market_id, target_market_id);
    let moduleAddress;
    if(target_market_id === 0) {
        moduleAddress = moduleAriesMarket;
    } else {
        moduleAddress = moduleEchelonMarket;
    }
    let func;
    if(source_market_id === 0) {
        func = `${moduleAddress}::migrate::migrate_from_aries`;
    } else {
        func = `${moduleAddress}::migrate::migrate_from_echelon`;
    }
    const coin = `${moduleAuritaCoin}::aurita_coin::${coinSymbol}`;
    const amount_in_wei = amount * 1000000;

    const payload = {
        data: {
            function: func,
            typeArguments: [coin],
            functionArguments: [amount_in_wei],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payload);
        return response;
    } catch(error) {
        console.log(error);
        return;
    }
}
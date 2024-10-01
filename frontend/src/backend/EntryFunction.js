import { aptos } from "../App.js";
import { moduleAddress } from "../App.js";

// coinSymbol: USDC, USDT, WBTC, STAPT, APT, WETH, CAKE
export async function deposit(coinSymbol, userAddress, amount, signAndSubmitTransaction) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;
    const onBehalfAddress = userAddress;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;

    const payLoad = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::supply`,
            typeArguments: [coin],
            functionArguments: [onBehalfAddress, amount_in_wei, iterations],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch {
        console.log(error);
        return;
    }
}

export async function borrow(coinSymbol, amount, signAndSubmitTransaction) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;

    const payLoad = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::borrow`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei, iterations],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch {
        console.log(error);
        return;
    }
}

export async function withdraw(coinSymbol, userAddress, amount, signAndSubmitTransaction) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;
    const receiver = userAddress;

    const payLoad = {
        data: {
            function: `${moduleAddress}::exit_positions_manager::withdraw`,
            typeArguments: [coin],
            functionArguments: [amount_in_wei, receiver, iterations],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch {
        console.log(error);
        return;
    }
}

export async function repay(coinSymbol, userAddress, amount, signAndSubmitTransaction) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;
    const iterations = 100;
    const amount_in_wei = amount * 1000000;
    const onBehalfAddress = userAddress;

    const payLoad = {
        data: {
            function: `${moduleAddress}::entry_positions_manager::borrow`,
            typeArguments: [coin],
            functionArguments: [onBehalfAddress, amount_in_wei, iterations],
        }
    };

    let result;
    try {
        const response = signAndSubmitTransaction(payLoad);
        return response;
    } catch {
        console.log(error);
        return;
    }
}


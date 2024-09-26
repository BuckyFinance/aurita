import { aptos } from "../App.js";
import { moduleAddress } from "../App.js";

export async function getUserSupply(coinSymbol, userAddress) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::user_len::get_total_supply`,
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

export async function getUserBorrow(coinSymbol, userAddress) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::user_len::get_total_borrow`,
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

export async function getDepositAPY(coinSymbol) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::market_lens::get_deposit_apy`,
        typeArguments: [coin],
        functionArguments: [],
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

export async function getBorrowAPY(coinSymbol) {
    const coin = `${moduleAddress}::coin::${coinSymbol}`;

    const payLoad = {
        function: `${moduleAddress}::market_lens::get_borrow_apy`,
        typeArguments: [coin],
        functionArguments: [],
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
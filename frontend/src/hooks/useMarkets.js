import tokenList from "../tokenList.json";
import { useEffect, useState } from "react";
import { getMarketDepositAPY, getBorrowAPY, getMarketLiquidity } from "../backend/ViewFunction";

export const useMarkets = (marketId) => {
    const [marketData, setMarketData] = useState(null);

    const fetchMarketData = async () => {
        let marketData = {};
        let promises = [];

        tokenList.forEach((token) => {
            console.log(token.ticker);
            promises.push(getMarketDepositAPY(token.ticker, marketId));
            promises.push(getBorrowAPY(token.ticker, marketId));
            promises.push(getMarketLiquidity(token.ticker, marketId));
        });

        promises = await Promise.all(promises);

        
        let index = 0;
        tokenList.forEach((token) => {
            marketData[token.ticker] = {
                'deposit_apy': promises[index * 3],
                'borrow_apy': promises[index * 3 + 1],
                'market_liquidity': promises[index * 3 + 2],
            }
            index++;
        });
        
        setMarketData(marketData);
    }

    useEffect(() => {
        fetchMarketData();
    }, [marketId]);

    return {marketData};
}
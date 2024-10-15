import tokenList from "../tokenList.json";
import { useEffect, useState } from "react";
import { getMarketDepositAPY, getBorrowAPY, getMarketLiquidity, getAssetPrice, getUserSupplyAPY, getTotalSupply, getTotalBorrow} from "../backend/ViewFunction";

export const useMarkets = (marketId) => {
    const [marketData, setMarketData] = useState(null);

    const fetchMarketData = async () => {
        let marketData = {};
        let promises = [];

        tokenList.forEach((token) => {
            promises.push(getMarketDepositAPY(token.ticker, marketId));
            promises.push(getBorrowAPY(token.ticker, marketId));
            promises.push(getMarketLiquidity(token.ticker, marketId));
            promises.push(getAssetPrice(token.ticker));
            promises.push(getUserSupplyAPY(token.ticker, marketId));
        });

        promises = await Promise.all(promises);

        let index = 0;
        tokenList.forEach((token) => {
            marketData[token.ticker] = {
                'deposit_apy': (promises[index * 5] / 1e18 * 100).toFixed(2),
                'borrow_apy': (promises[index * 5 + 1] / 1e18 * 100).toFixed(2),
                'market_liquidity': promises[index * 5 + 2] / 1e6,
                'price': promises[index * 5 + 3] / 1e18,  
                'p2p_apy': (promises[index * 5 + 4] / 1e18 * 100).toFixed(2),
            }
            index++;
        });
        
        promises = [
            getTotalSupply(marketId),
            getTotalBorrow(marketId)
        ];

        promises = await Promise.all(promises);
        marketData['total_supplied'] = promises[0] / 1e24;
        marketData['total_borrowed'] = promises[1] / 1e24;

        setMarketData(marketData);
    }

    useEffect(() => {
        setMarketData(null);
        fetchMarketData(); // Fetch data when marketId changes

        // Set an interval to fetch data every 5 seconds
        const interval = setInterval(() => {
            fetchMarketData();
        }, 10000);

        // Cleanup the interval when component unmounts or marketId changes
        return () => clearInterval(interval);
    }, [marketId]);

    return {marketData};
}
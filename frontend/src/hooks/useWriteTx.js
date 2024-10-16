import { useEffect, useState } from "react";
import { supply, borrow, withdraw, repay, migrate } from "../backend/EntryFunction";

export const useMarketAction = (marketId, action, coinSymbol, amount, walletAddress, signer) => {
    const [isPending, setIsPending] = useState(false);
    const [isSuccess, setIsSuccess] = useState(false);
    const [isFailed, setIsFailed] = useState(false);

   

    const execute = async (sourceMarket) => {
        setIsPending(true);
        try{
            if(action == 'Supply'){
                await supply(coinSymbol, walletAddress, amount, marketId, signer);
            }else if(action == 'Borrow'){
                await borrow(coinSymbol, amount, marketId, signer);
            }else if(action == 'Withdraw'){
                await withdraw(coinSymbol, walletAddress, amount, marketId, signer);
            }else if(action == 'Repay'){
                await repay(coinSymbol, walletAddress, amount, marketId, signer);
            }else if(action == "Migrate"){
                console.log(coinSymbol);
                for(let i = 0; i < coinSymbol.length; i++){
                    const position = coinSymbol[i];
                    await new Promise(r => setTimeout(r, 200));

                    await migrate(position.token.ticker, position.amount, sourceMarket, marketId, signer);
                }
            }
        }catch(error){
            console.log(error);
            setIsPending(false);
            setIsSuccess(false);
            setIsFailed(true);
            return false;
        }

        
        setIsPending(false);
        setIsSuccess(true);
        setIsFailed(false);

        console.log(action, 'success');
        return true;
    }

    return {isPending, isSuccess, isFailed, execute};
};
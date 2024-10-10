import { useEffect, useState } from "react";
import { supply, borrow, withdraw, repay } from "../backend/EntryFunction";

export const useMarketAction = (marketId, action, coinSymbol, amount, walletAddress, signer) => {
    const [isPending, setIsPending] = useState(false);
    const [isSuccess, setIsSuccess] = useState(false);
    const [isFailed, setIsFailed] = useState(false);

    const execute = async () => {
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
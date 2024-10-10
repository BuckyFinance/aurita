import { useEffect, useState } from "react";
import { getUserAllBorrowPositions, getUserAllSupplyPositions, getUserSupplyAmount, getUserBorrowAmount, getUserSupplyAPY, getUserBorrowAPY } from "../backend/ViewFunction";

export const useAccount = (walletAddress, marketId) => {
    const [accountData, setAccountData] = useState(null);

    const SUPPLY = 0;
    const BORROW = 1;

    const fetchAccountPositions = async () => {
        let promises = [
            getUserAllSupplyPositions(walletAddress, marketId),
            getUserAllBorrowPositions(walletAddress, marketId)
        ];

        promises = await Promise.all(promises);

        return promises;
    }

    const fetchPositionDataBySymbol = (coinSymbol, positionType) => {
        let promises = []

        if(positionType == SUPPLY){
            promises = [
                getUserSupplyAmount(coinSymbol, walletAddress, marketId),
                getUserSupplyAPY(coinSymbol, marketId)
            ];
        }else{
            promises = [
                getUserBorrowAmount(coinSymbol, walletAddress, marketId),
                getUserBorrowAPY(coinSymbol, marketId)
            ];
        }

        return promises;
    }

    const fetchPositionData = async() => {
        if(!walletAddress){
            return;
        }
        
        const positions = await fetchAccountPositions();
        let account_data = {};
        account_data['positions'] = {}
        
        let data = [];

        for(let type = 0; type < 2; type++){
            if(!positions[type]){
                continue;
            }

            let promises = [];

            positions[type].forEach(token => {
                promises = promises.concat(fetchPositionDataBySymbol(token, type));
            });
            promises = await Promise.all(promises);
            data.push(promises);
        }

        for(let type = 0; type < 2; type++){
            let _data = {};
            if(!positions[type]){
                continue;
            }

            
            for(let index = 0; index < positions[type].length; index++){
                const token = positions[type][index];
                _data[token] = {
                    'amount': data[type][index * 2] / 1e6,
                    'apy': data[type][index * 2 + 1] / 1e18,
                }
            }

            if(type == SUPPLY){
                account_data['positions']['supply'] = _data;
            }else{
                account_data['positions']['borrow'] = _data;
            }
        }

        setAccountData(account_data);
    }

    useEffect(() => {
        fetchPositionData();
    }, [walletAddress, marketId]);


    return {accountData};
}
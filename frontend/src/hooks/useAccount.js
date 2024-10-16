import { useEffect, useState } from "react";
import { getCoinDepositedForMigrate, getAmountDepositedForMigrate, getUserAllBorrowPositions, getUserHealthFactor, getUserBorrowable, getUserAllSupplyPositions, getUserBalance, getUserSupplyAmount, getUserBorrowAmount, getUserSupplyAPY, getUserBorrowAPY } from "../backend/ViewFunction";
import tokenList from "../tokenList.json";

export const useAccount = (walletAddress, marketId, tokenList) => {
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

    const fetchAccountBalance = async () => {
        let promises = []
        
        tokenList.forEach((token) => {
            promises.push(getUserBalance(walletAddress, token.ticker, marketId));
        });

        let data = await Promise.all(promises);
        data = data.map(e => e / 1e6);

        return data;
    }

    const fetchPositionData = async() => {
        if(!walletAddress){
            setAccountData(null);
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

                if(data[type][index * 2] == 0){
                    delete _data[token];
                }
            }

            if(type == SUPPLY){
                account_data['positions']['supply'] = _data;
            }else if(Object.keys(_data).length){
                account_data['positions']['borrow'] = _data;
            }
        }
    
        // account_data['health_factor'] = await getUserHealthFactor(walletAddress, marketId) / 1e18;
        // console.log(account_data['health_factor']);

        account_data['balance'] = await fetchAccountBalance();
        account_data['balance_by_ticker'] = {}
        tokenList.forEach((token, index) => {
            account_data['balance_by_ticker'][token.ticker] = account_data['balance'][index];
        });
        
        account_data['borrowable'] = await getUserBorrowable(walletAddress, marketId) / 1e6;

        setAccountData(account_data);
    }

    useEffect(() => {
        setAccountData(null);
        fetchPositionData(); // Fetch data immediately when walletAddress or marketId changes

        // Set an interval to fetch data every 10 seconds
        const interval = setInterval(() => {
            fetchPositionData();
        }, 3000); // Fetch every 10 seconds

        // Cleanup the interval when component unmounts or walletAddress/marketId changes
        return () => clearInterval(interval);
    }, [walletAddress, marketId]);


    return {accountData};
}

export const useMigrate = (walletAddress, marketId) => {
    const [migrateData, setMigrateData] = useState(null);

    const fetchMigrationData = async () => {
        let data = [];
        try{
            let promises = [
                getCoinDepositedForMigrate(walletAddress, marketId), 
                getAmountDepositedForMigrate(walletAddress, marketId),
            ];
            
            promises = await Promise.all(promises);


            promises[0].forEach((token, index) => {
                data.push({
                    "token": tokenList.filter(_token => _token.ticker == token)[0],
                    "amount": promises[1][index] / 1e6,
                });
            });
        }catch{
        }

        setMigrateData(data);
    }  

    useEffect(() => {
        setMigrateData(null);
        fetchMigrationData(); // Fetch data immediately when walletAddress or marketId changes

        // Set an interval to fetch data every 10 seconds
        const interval = setInterval(() => {
            fetchMigrationData();
        }, 3000); // Fetch every 10 seconds

        // Cleanup the interval when component unmounts or walletAddress/marketId changes
        return () => clearInterval(interval);
    }, [walletAddress, marketId]);

    return {migrateData};
}
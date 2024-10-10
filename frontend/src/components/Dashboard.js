import React, { useState, useEffect, useRef} from "react";
import { Input, Popover, Radio, Modal, message } from "antd";
import {
  ArrowDownOutlined,
  DownOutlined,
  SettingOutlined,
} from "@ant-design/icons";
import tokenList from "../tokenList.json";

import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import { useLocation } from "react-router-dom";
import empty from "../media/empty2.svg";
import { useWallet, InputTransactionData, InputViewFunctionData } from "@aptos-labs/wallet-adapter-react";

import { mintCoin } from "../backend/EntryFunction";
import { getBorrowAPY, getMarketDepositAPY, getMarketLiquidity } from "../backend/ViewFunction";
import { getUserAllBorrowPositions, getUserAllSupplyPositions, getUserSupplyAmount } from "../backend/ViewFunction";
import Spinner from "../media/spinner.svg";
import { Flex, Spin } from 'antd';
import { LoadingOutlined } from '@ant-design/icons';
import { Skeleton } from 'antd';


function Dashboard(props){
    const { account, signAndSubmitTransaction } = useWallet();
    const [totalCollateral, setTotalCollateral] = useState(0);
    const [totalLoan, setTotalLoan] = useState(0);

    const accountData = props.accountData;
    const marketData = props.marketData;
    function DataBox(props){
        return (
            <div className="box">
                <div className="box-name">
                    {props.name}
                </div>
                <div className="box-content">
                    <div>
                    {props.boxContent}
                    {/* <Skeleton
                    avatar
                    style={{
                        backgroundColor: 'rgba(255, 255, 255, 0.1)', // Adjust transparency if needed
                        color: 'white', // Text color for skeleton lines
                    }}
                    active
                    /> */}



                    </div>
                </div>
            </div>
        )
    }

    function formatNumber(value) {
        if (value >= 1_000_000) {
            return (value / 1_000_000).toFixed(2) + 'M';
        } else if (value >= 1_000) {
            return (value / 1_000).toFixed(2) + 'K';
        } else {
            return value.toString();
        }
    }
    
    useEffect(() => {
        if(marketData && accountData){
            let total = 0;

            if(accountData['positions']['supply']){
                Object.entries(accountData['positions']['supply']).map(([collateral, data]) => {
                    total += marketData[collateral]['price'] * data.amount;
                });
                setTotalCollateral(total);
            }

            total = 0;

            if(accountData['positions']['borrow']){
                Object.entries(accountData['positions']['borrow']).map(([collateral, data]) => {
                    total += marketData[collateral] * data.amount;
                });
                setTotalLoan(total);
            }
        }
    }, [marketData, accountData]);
    // async function MintToken(){
    //     await mintCoin("WETH", account.address, 10000000, 0, signAndSubmitTransaction);
    //     console.log("MINTED");
    // }

    async function f(){
        console.log(props.accountData);
        console.log(await getUserSupplyAmount("WBTC", account.address, 0) / 1e6);
    }

    
    return (
        <>
                {/* <button onClick={() => f()}>MINT</button> */}
            <div className="dashboard">
                <div className="infoBox">
                    <DataBox name='Total collateral' boxContent={`$${formatNumber(totalCollateral)}`}></DataBox>
                    <DataBox name='Total loan' boxContent={`$${formatNumber(totalLoan)}`}></DataBox>
                    <DataBox name='Health factor' boxContent='0.56'></DataBox>
                </div>
                <div className="dashboard-container2">
                    <div className="dashboardBox" style={{marginRight: '1em'}}>
                        <div className="boxDescription">
                            Your Collateral
                        </div>
                        {!accountData && <Flex align="center" gap="middle" style={{flexDirection: 'column', height: '50vh', width: '100%'}}>
                            <div style={{alignItems: 'center', justifyContent: 'center', display: 'flex', height: '50vh', flexDirection: 'column'}}>
                                <Spin indicator={<LoadingOutlined style={{ fontSize: 96}} spin />} />
                                <p style={{color: 'rgb(64, 67, 77)', fontWeight: 'bold', fontSize: 'larger'}}>Working on it...</p>
                            </div>
                        </Flex>
                        }
                        {(accountData && accountData['positions']['supply']) &&  <TableContainer component={Paper}>
                        <Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
                            <TableHead >
                                <TableRow >
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Amount</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">APY</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                            {Object.entries(accountData['positions']['supply']).map(([collateral, data]) => ((collateral) => (
                                <TableRow
                                key={collateral.name}
                                sx= {{ 'td': { border: 0 }, 'th': { border: 0 }, '&:hover': {
                                        backgroundColor: '#363e54', 	
                                    }, backgroundColor: '#131724', 
                                    transition: 'background-color 0.3s ease'
                                }}
                                className="marketRow"
                                >
                                    <TableCell style={{borderTopLeftRadius: '10px',
                                        borderBottomLeftRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} component="th" scope="row">
                                        <div style={{display: 'flex', gap: '5px'}}>
                                            <img src={collateral.img} alt={collateral.ticker} className='tokenLogo'></img>
                                            {collateral.ticker}
                                        </div>
                                    </TableCell>
                                    <TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{data.amount}</TableCell>
                                    <TableCell style={{borderTopRightRadius: '10px',
                                        borderBottomRightRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{data.apy}%</TableCell>
                                </TableRow>
                            ))(tokenList.filter(token => token.ticker == collateral)[0]))}
                            </TableBody>
                        </Table>
                        </TableContainer>
                        }
                        
                        {(accountData && !accountData['positions']['supply']) &&    <div className="empty">
                                <div style={{display: 'flex', flexDirection: 'column'}}>
                                    <div>
                                        <img src={empty} className='emptyimg' style={{width: '40%', height: '40%'}}></img>
                                    </div>
                                    <div>
                                    You have no collateral
                                    </div>
                                </div>
                            </div>  
                        }
                    </div>
                    <div className="dashboardBox" style={{marginRight: '1em'}}>
                        <div className="boxDescription">
                            Your Loan
                        </div>
                        {!accountData && <Flex align="center" gap="middle" style={{flexDirection: 'column', height: '50vh', width: '100%'}}>
                            <div style={{alignItems: 'center', justifyContent: 'center', display: 'flex', height: '50vh', flexDirection: 'column'}}>
                                <Spin indicator={<LoadingOutlined style={{ fontSize: 96}} spin />} />
                                <p style={{color: 'rgb(64, 67, 77)', fontWeight: 'bold', fontSize: 'larger'}}>Working on it...</p>
                            </div>
                        </Flex>
                        }
                        {(accountData && accountData['positions']['borrow']) &&  <TableContainer component={Paper}>
                        <Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
                            <TableHead >
                                <TableRow >
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Amount</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">APY</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                            {Object.entries(accountData['positions']['borrow']).map(([collateral, data]) => ((collateral) => (
                                <TableRow
                                key={collateral.name}
                                sx= {{ 'td': { border: 0 }, 'th': { border: 0 }, '&:hover': {
                                        backgroundColor: '#363e54', 	
                                    }, backgroundColor: '#131724', 
                                    transition: 'background-color 0.3s ease'
                                }}
                                className="marketRow"
                                >
                                    <TableCell style={{borderTopLeftRadius: '10px',
                                        borderBottomLeftRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} component="th" scope="row">
                                        <div style={{display: 'flex', gap: '5px'}}>
                                            <img src={collateral.img} alt={collateral.ticker} className='tokenLogo'></img>
                                            {collateral.ticker}
                                        </div>
                                    </TableCell>
                                    <TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{data.amount}</TableCell>
                                    <TableCell style={{borderTopRightRadius: '10px',
                                        borderBottomRightRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{data.apy}%</TableCell>
                                </TableRow>
                            ))(tokenList.filter(token => token.ticker == collateral)[0]))}
                            </TableBody>
                        </Table>
                        </TableContainer>
                        }
                        
                        {(accountData && !accountData['positions']['borrow']) &&    <div className="empty">
                                <div style={{display: 'flex', flexDirection: 'column'}}>
                                    <div>
                                        <img src={empty} className='emptyimg' style={{width: '40%', height: '40%'}}></img>
                                    </div>
                                    <div>
                                    You have no loan
                                    </div>
                                </div>
                            </div>  
                        }
                    </div>
                </div>
            </div>
        </>
    );
}

export default Dashboard;
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

function Dashboard(props){
    const { account, signAndSubmitTransaction } = useWallet();

    function DataBox(props){
        return (
            <div className="box">
                <div className="box-name">
                    {props.name}
                </div>
                <div className="box-content">
                    <div>
                    {props.boxContent}
                    </div>
                </div>
            </div>
        )
    }

    const collateral = [
        {
            token: tokenList[0],
            amount: 123.23,
            apy: 5.66
        },
        {
            token: tokenList[1],
            amount: 5.23,
            apy: 15.50
        },
        {
            token: tokenList[2],
            amount: 5385.23,
            apy: 0.22
        },
    ]


    // async function MintToken(){
    //     await mintCoin("WETH", account.address, 10000000, 0, signAndSubmitTransaction);
    //     console.log("MINTED");
    // }

    async function f(){
        console.log(await getUserSupplyAmount("WBTC", account.address, 0));
    }

    
    return (
        <>
                <button onClick={() => f()}>MINT</button>
            <div className="dashboard">
                <div className="infoBox">
                    <DataBox name='Total collateral' boxContent='$1234.39'></DataBox>
                    <DataBox name='Total borrowed' boxContent='$538.39'></DataBox>
                    <DataBox name='Health factor' boxContent='0.56'></DataBox>
                </div>
                <div className="dashboard-container2">
                    <div className="dashboardBox" style={{marginRight: '1em'}}>
                        <div className="boxDescription">
                            Your Collateral
                        </div>
                        <TableContainer component={Paper}>
                        <Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
                            <TableHead >
                                <TableRow >
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Amount</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">APY</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                            {collateral.map((collateral) => (
                                <TableRow
                                key={collateral.token.name}
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
                                            <img src={collateral.token.img} alt={collateral.token.ticker} className='tokenLogo'></img>
                                            {collateral.token.ticker}
                                        </div>
                                    </TableCell>
                                    <TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{collateral.amount}</TableCell>
                                    <TableCell style={{borderTopRightRadius: '10px',
                                        borderBottomRightRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{collateral.apy}%</TableCell>
                                </TableRow>
                            ))}
                            </TableBody>
                        </Table>
                        </TableContainer>
                            {/* <div className="empty">
                            <div style={{display: 'flex', flexDirection: 'column'}}>
                                <div>
                                    <img src={empty} className='emptyimg' style={{width: '40%', height: '40%'}}></img>
                                </div>
                                <div>
                                You have no collateral
                                </div>
                            </div>
                        </div> */}
                    </div>
                    <div className="dashboardBox" style={{marginLeft: '1em'}}>
                        <div className="boxDescription">
                            Your Loan
                        </div>
                        <div className="empty">
                            <div style={{display: 'flex', flexDirection: 'column', gap: '20px'}}>
                                <div>
                                    <img src={empty} className='emptyimg' style={{width: '40%', height: '40%'}}></img>
                                </div>
                                <div style={{fontSize: 'large'}}>
                                    You have no loan
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
}

export default Dashboard;
import React from "react";
import Logo from "../jelly3.png";
import Eth from "../eth.svg";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
import { Col } from "antd";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";

import { Link } from "react-router-dom";
import Aries from "./../media/aries.png"
import Echelon from "./../media/echelon.png"
import { useState, useEffect, useRef} from "react";
import { Input, Popover, Radio, Modal, message } from "antd";
import empty from "../media/empty2.svg";

import { Checkbox, Divider } from 'antd';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import Check from "./../media/check.svg"
function Migrate(){

    const [isModalOpen, setIsModalOpen] = useState(false);
	const [market, setMarket] = useState({
		"market": "Aries",
		"img": Aries
	});
	
	const marketList = [
		{
			"market": "Aries",
			"img": Aries
		}, 
		{
			"market": "Echelon",
			"img": Echelon
		}
	];


    const tokenList = [
        {
            "ticker": "USDC",
            "img": "https://cdn.moralis.io/eth/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
            "name": "USD Coin",
            "address": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
            "decimals": 6
        },
        {
            "ticker": "LINK",
            "img": "https://cdn.moralis.io/eth/0x514910771af9ca656af840dff83e8264ecf986ca.png",
            "name": "Chainlink",
            "address": "0x514910771af9ca656af840dff83e8264ecf986ca",
            "decimals": 18
        },
        {
            "ticker": "USDT",
            "img": "https://cdn.moralis.io/eth/0xdac17f958d2ee523a2206206994597c13d831ec7.png",
            "name": "Tether USD",
            "address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
            "decimals": 6
        },
        {
            "ticker": "GUSD",
            "img": "https://cdn.moralis.io/eth/0x056fd409e1d7a124bd7017459dfea2f387b6d5cd.png",
            "name": "Gemini USD",
            "address": "0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd",
            "decimals": 2
        },
    ]
    
    const [selectedRows, setSelectedRows] = useState([]);


    const handleRowSelection = (id) => {
        console.log(id);
        setSelectedRows((prevSelected) =>
          prevSelected.includes(id)
            ? prevSelected.filter((rowId) => rowId !== id)
            : [...prevSelected, id]
        );
      };
    
    return (
        <>
            <Modal
                open={isModalOpen}
                footer={null}
                onCancel={() => setIsModalOpen(false)}
                title="Migrate from"
                className="appModal"
            >
                <div className="modalContent">
                {marketList?.map((e, i) => {
                    return (
                    <div
                        className="tokenChoice"
                        key={i}
                        onClick={() => {setMarket(e); setIsModalOpen(false)}}
                        style={{gap: '20px', fontFamily: 'Montserrat', justifyContent: 'space-between'}}
                    >
                        <div style={{display: 'flex', flexDirection: 'row', gap: '20px'}}>
                            <img src={e.img} height={48} />
                            <div style={{fontSize: '2em', fontWeight: 'bold'}}>
                                {e.market}
                            </div>
                        </div>
                    </div>
                    );
                })}
                </div>
            </Modal>

            <div style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: '2em', width:'100%'}}>
                <div style={{fontSize: '3em', display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '20px'}} onClick={() => setIsModalOpen(true)}>
                    Migrate from <span>
                        <div className="migrate-selection">
                            <img src={market.img}></img>
                            <div >
                                {market.market}
                            </div>
                            {/* <svg style={{transform: 'scale(1.5)'}} fill="none" height="7" width="14" xmlns="http://www.w3.org/2000/svg"><title>Dropdown</title><path d="M12.75 1.54001L8.51647 5.0038C7.77974 5.60658 6.72026 5.60658 5.98352 5.0038L1.75 1.54001" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" xmlns="http://www.w3.org/2000/svg"></path></svg> */}
                        </div>
                    </span>
                </div>

                <div className="migrateBox">
                    {/* <div className="empty">
                        <div style={{display: 'flex', flexDirection: 'column', gap: '20px'}}>
                            <div>
                                <img src={empty} className='emptyimg' style={{width: '35%', height: '35%'}}></img>
                            </div>
                            <div style={{fontSize: 'large'}}>
                                You have no position on {market.market}
                            </div>
                        </div>
                        
                    </div> */}
                    <div style={{display: 'flex', flexDirection: 'column', justifyContent: 'space-between', width: '100%', height: '100%', alignItems: 'left'}}>
                        <Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
                            <TableHead >
                                <TableRow >
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Amount</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">P2P APY</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                            {tokenList.map((token, index) => (
                                <TableRow
                                key={token.name}
                                sx= {{ 'td': { border: 0 }, 'th': { border: 0 }, '&:hover': {
                                        backgroundColor: '#363e54', 	
                                    }, backgroundColor: '#131724', 
                                    transition: 'background-color 0.3s ease'
                                }}
                                className={["marketRow"].join(' ')}
                                onClick={() => handleRowSelection(index)}
                                >
                                    <TableCell className={selectedRows.includes(index) ? "selected-row" : "not-selected"} style={{borderTopLeftRadius: '10px',
                                        borderBottomLeftRadius: '10px',fontFamily: 'Kanit', fontSize: 16}} component="th" scope="row">
                                        <div style={{borderTopLeftRadius: '10px',
                                                borderBottomLeftRadius: '10px', display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '5px'}}>
                                            <img src={token.img} height={24}></img>
                                            {token.ticker}
                                        </div>
                                    </TableCell>
                                    <TableCell className={selectedRows.includes(index) ? "selected-row" : "not-selected"} style={{fontFamily: 'Kanit', fontSize: 16}} align="left">100.00</TableCell>
                                    <TableCell className={selectedRows.includes(index) ? "selected-row" : "not-selected"} style={{borderTopRightRadius: '10px',
                                        borderBottomRightRadius: '10px',width: '28%', fontFamily: 'Kanit', fontSize: 16}} align="left">100.00%</TableCell>
                                </TableRow>
                            ))}
                            </TableBody>
                        </Table>
                    </div>
                </div>
                
                <div style={{width: '20%'}} >
                    <div className="migrateButton" disabled={selectedRows.length == 0}>
                        Migrate {selectedRows.length > 0 && (
                            <>
                                {selectedRows.length} position{selectedRows.length > 1 ? 's' : ''}
                            </>
                        )}
                    </div>
                </div>
            </div>
        </>
    )
}

export default Migrate;
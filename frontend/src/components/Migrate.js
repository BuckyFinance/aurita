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
import {Flex, Spin} from "antd";
import { LoadingOutlined } from "@ant-design/icons";

import { Checkbox, Divider } from 'antd';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import ShiningText from "./ShiningText";
import { useMarketAction } from "../hooks/useWriteTx";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import Connect from "../media/connect2.svg"
import Success from "../media/success.svg";
import Failed from "../media/failed.svg";
import { useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { useMarkets } from "../hooks/useMarkets";
import { useMigrate } from "../hooks/useAccount";

function Migrate(props){
    const { account, signAndSubmitTransaction } = useWallet();
    const [isModalOpen, setIsModalOpen] = useState(false);
	const [marketFrom, setMarketFrom] = useState({
        "market": "Aries",
		"img": Aries,
        "id": 0
	});
    const accountData = props.accountData;
    const marketData = props.marketData;
    const market = props.market;
    const [selectedRows, setSelectedRows] = useState([]);
    const navigate = useNavigate();
    
    const accountNavigateData = useMemo(() => accountData ? accountData.migrate : 0, []);
    
    const {marketData : marketSourceData} = useMarkets(marketFrom.id);
    const {migrateData} = useMigrate(account ? account.address : null, marketFrom.id);
    const {isPending, isSuccess, isFailed, execute} = useMarketAction(market.id, "Migrate", migrateData ?  migrateData.filter((_, index) => selectedRows.includes(index)) : null, 0, account ? account.address : null, signAndSubmitTransaction);
    
    useEffect(() => {
        setSelectedRows([]);
    }, [accountNavigateData]);
	
	const marketList = [
		{
			"market": "Aries",
			"img": Aries,
            "id": 0,
		}, 
		{
			"market": "Echelon",
			"img": Echelon,
            "id": 1
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
    


    const handleRowSelection = (id) => {
        console.log(id);
        setSelectedRows((prevSelected) =>
          prevSelected.includes(id)
            ? prevSelected.filter((rowId) => rowId !== id)
            : [...prevSelected, id]
        );
      };

      const [stars, setStars] = useState([]);

      useEffect(() => {
        const numStars = 6; // Number of stars
        const newStars = [];
    
        for (let i = 0; i < numStars; i++) {
          // Random size between 50px and 80px
          const size = Math.floor(Math.random() * 31) + 50; // 50 to 80px
    
          // Random position within the parent element
          const top = Math.floor(Math.random() * 80); // Limit to 80% to avoid overflow
          const left = Math.floor(Math.random() * 80); // Limit to 80%
    
          // Random animation delay between 0 and 3 seconds
          const delay = (Math.random() * 3).toFixed(2);
    
          // Random z-index to place star in front of or behind the text
          const zIndex = Math.random() < 0.5 ? -1 : 1;
    
          // Random initial rotation angle between 0deg and 360deg
          const rotation = Math.floor(Math.random() * 361); // 0 to 360 degrees
    
          // Create a star object with the generated properties
          newStars.push({
            id: i,
            size,
            top,
            left,
            delay,
            zIndex,
            rotation,
          });
        }
    
        setStars(newStars);
      }, []); // Empty dependency array to run once on mount
    
      const [messageApi, contextHolder] = message.useMessage();

      const [showTransactionResult, setShowTransactionResult] = useState(false);
	const [transactionStatus, setTransactionStatus] = useState("successful");
    useEffect(() => {
		if(isPending){
			messageApi.destroy();
			messageApi.open({
				type: 'loading',
				content: 'Transaction is Pending...',
				duration: 0,
			})
		}else{
			messageApi.destroy();
			if(isSuccess){
				// messageApi.open({
				//   type: 'success',
				//   content: 'Transaction Successful',
				//   duration: 1.5,
				// })
				setTransactionStatus("successful");
				setShowTransactionResult(true);
			}else if(isFailed){
				// messageApi.open({
				// 	type: 'error',
				// 	content: 'Transaction Failed',
				// 	duration: 1.50,
				// })
				setTransactionStatus("failed");
				setShowTransactionResult(true);
			}
		}
	}, [isPending, isSuccess, isFailed]);

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
                        onClick={() => {setMarketFrom(e); setIsModalOpen(false)}}
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

            <Modal
			open={showTransactionResult}
			footer={null}
			onCancel={() => setShowTransactionResult(false)}
			title={["Transaction", transactionStatus].join(' ')}
			className="appModal"
			width={400}
			>
				<div className="modalContent">
					<div style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: '1em'}}>
						{transactionStatus == "successful" && 
							<>
							<img src={Success} width="25%" style={{marginTop: "1em"}}></img>
							<div style={{fontSize: "larger", fontWeight: 'bold', fontFamily: "Montserrat"}}>
								Successfully migrated
							</div>
							</>
						}

						{transactionStatus != "successful" && 
							<>
								<img src={Failed} width="25%" style={{marginTop: "1em"}}></img>
								<div style={{fontSize: "larger", fontWeight: 'bold', fontFamily: "Montserrat"}}>
									Migration failed
								</div>
							</>
						}						

						<div style={{marginTop: "1em"}}>
							<div style={{display: 'flex', flexDirection: 'row'}}>
								<div className="generalButton" style={{marginRight: '1em'}} onClick={() => {
									navigate("/app");
								}}>
									Dashboard
								</div>

								<div className="generalButton" onClick={() => setShowTransactionResult(false)}>
									Done
								</div>
							</div>
						</div>
					</div>
				</div>
			</Modal>

            <div style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: '2em', width:'100%'}}>
                <div style={{fontSize: '3em', display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '20px'}} onClick={() => setIsModalOpen(true)}>
                    Migrate from <span>
                        <div className="migrate-selection">
                            <img src={marketFrom.img}></img>
                            <div >
                                {marketFrom.market}
                            </div>
                            {/* <svg style={{transform: 'scale(1.5)'}} fill="none" height="7" width="14" xmlns="http://www.w3.org/2000/svg"><title>Dropdown</title><path d="M12.75 1.54001L8.51647 5.0038C7.77974 5.60658 6.72026 5.60658 5.98352 5.0038L1.75 1.54001" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" xmlns="http://www.w3.org/2000/svg"></path></svg> */}
                        </div>
                    </span>
                </div>

                <div className="migrateBox">
                    <div style={{display: 'flex', flexDirection: 'column', justifyContent: 'space-between', width: '100%', height: '100%', alignItems: 'left'}}>
                    {marketData && marketSourceData && migrateData && migrateData.length && 
                    <Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
                            <TableHead >
                                <TableRow >
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Amount</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">{marketFrom.market} APY</TableCell>
                                    <TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">{market.market} P2P APY</TableCell>

                                </TableRow>
                            </TableHead>
                            <TableBody>
                            {migrateData.map((position, index) => (
                                <TableRow
                                key={position.token.name}
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
                                            <img src={position.token.img} height={24}></img>
                                            {position.token.ticker}
                                        </div>
                                    </TableCell>
                                    <TableCell className={selectedRows.includes(index) ? "selected-row" : "not-selected"} style={{fontFamily: 'Kanit', fontSize: 16}} align="left">{position.amount}</TableCell>
                                    <TableCell className={selectedRows.includes(index) ? "selected-row" : "not-selected"} style={{fontFamily: 'Kanit', fontSize: 16}} align="left">{marketSourceData[position.token.ticker].deposit_apy}%</TableCell>
                                    <TableCell className={[selectedRows.includes(index) ? "selected-row" : "not-selected"].join(' ')} style={{borderTopRightRadius: '10px',
                                        borderBottomRightRadius: '10px', fontFamily: 'Kanit', fontSize: 16}} align="left">
                                            <ShiningText isSelected={selectedRows.includes(index) ? true : false} text={[marketData[position.token.ticker].p2p_apy, "%"].join("")}/>
                                    </TableCell>
                                </TableRow>
                            ))
                            }
                            </TableBody>
                        </Table>
                        }

                        {account && (!migrateData || !marketSourceData || !marketData) &&
                                 <Flex align="center" gap="middle" style={{flexDirection: 'column', height: '50vh', width: '100%'}}>
                                    <div style={{alignItems: 'center', justifyContent: 'center', display: 'flex', height: '50vh', flexDirection: 'column'}}>
                                        <Spin indicator={<LoadingOutlined style={{ fontSize: 96}} spin />} />
                                        <p style={{color: 'rgb(64, 67, 77)', fontWeight: 'bold', fontSize: 'larger'}}>Working on it...</p>
                                    </div>
                                </Flex>
                            }
                        {!account && <div className="empty">
                            <div style={{display: 'flex', flexDirection: 'column'}}>
                                <div>
                                    <img src={Connect} className='emptyimg' style={{width: '25%', height: '25%'}}></img>
                                </div>
                                <div style={{fontSize: "larger"}}>
                                Please connect wallet!
                                </div>
                            </div>
                        </div>  }


                        {marketData && accountData && migrateData && marketSourceData && migrateData.length == 0

                            &&   <div className="empty">
                            <div style={{display: 'flex', flexDirection: 'column'}}>
                                <div>
                                    <img src={empty} className='emptyimg' style={{width: '40%', height: '40%'}}></img>
                                </div>
                                <div>
                                You have no position on {marketFrom.market}
                                </div>
                            </div>
                        </div>  
                        }
                    </div>
                </div>
                
                <div style={{width: '20%'}} >
                    <div className="migrateButton" disabled={selectedRows.length == 0} onClick={() => execute(marketFrom.id)}>
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
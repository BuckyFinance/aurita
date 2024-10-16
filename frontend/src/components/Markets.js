import React, { useState, useEffect, useRef} from "react";
import { Input, Popover, Radio, Modal, message } from "antd";
import {
  ArrowDownOutlined,
  DownOutlined,
  SettingOutlined,
} from "@ant-design/icons";
import tokenList from "../tokenList.json";
import { useWallet, InputTransactionData, InputViewFunctionData } from "@aptos-labs/wallet-adapter-react";

import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import { Navigate, useLocation } from "react-router-dom";
import { useMarkets } from "../hooks/useMarkets";
import { useMarketAction } from "../hooks/useWriteTx";
import { Skeleton } from 'antd';
import ShiningText from "./ShiningText";
import Success from "../media/success.svg";
import Failed from "../media/failed.svg";
import { useNavigate } from 'react-router-dom';


const MemoizedSkeletonNode = React.memo(() => (
    <Skeleton.Node
      active
      style={{
        width: 160,
        height: 48,
        marginTop: -20,
      }}
    />
  ));

function DataBox(props){
	return (
		<div className="box">
			<div className="box-name">
				{props.name}
			</div>
			<div className="box-content">
				<div>
				{props.loaded && props.boxContent}
				{!props.loaded && <MemoizedSkeletonNode/>}



				</div>
			</div>
		</div>
	)
}

function Markets(props) {
	const market = props.market;
	const marketData = props.marketData;
	const accountData = props.accountData;

	const [isOpen, setIsOpen] = useState(false);
	const [isModalOpen, setIsModalOpen] = useState(false);
	const [token, setToken] = useState(tokenList[0]);

	const [selectedTab, setSelectedTab] = useState(0);
	const tabRefs = useRef([]);
	const [underlineStyle, setUnderlineStyle] = useState({ width: 0, transform: 'translateX(0px)' });

	const location = useLocation();
    const { account, signAndSubmitTransaction } = useWallet();
	const [tokenAmount, setTokenAmount] = useState(100);

	const [showTransactionResult, setShowTransactionResult] = useState(false);
	const [transactionStatus, setTransactionStatus] = useState("successful");

	const [messageApi, contextHolder] = message.useMessage();
	
	const navigate = useNavigate();

	useEffect(() => {
		setIsOpen(false);
		tabRefs.current = [];
		setUnderlineStyle({ width: 0, transform: 'translateX(0px)' });
		console.log("Route changed or re-clicked", location.pathname);
	}, [location]);
	
	useEffect(() => {
		if (tabRefs.current[selectedTab]) {
			console.log(tabRefs);
			const tabElement = tabRefs.current[selectedTab];
			setUnderlineStyle({
				width: tabElement.offsetWidth,
				transform: `translateX(${tabElement.offsetLeft}px)`
			});
		}
	}, [selectedTab]);
	
	useEffect(() => {
		if (tabRefs.current[selectedTab]) {
			const tabElement = tabRefs.current[selectedTab];
			setTokenAmount(null);
			setUnderlineStyle({
				width: tabElement.offsetWidth,
				transform: `translateX(${tabElement.offsetLeft}px)`
			});
		}
	}, [isOpen]);
	
	const tabs = ['Supply', 'Withdraw', 'Borrow', 'Repay'];
	const pastTabs = ['supplied', 'withdrawn', 'borrowed', 'repaid']
	
	const changeTab = (tabIndex) => {
		setSelectedTab(tabIndex);
	};
	const {isPending, isSuccess, isFailed, execute} = useMarketAction(market.id, tabs[selectedTab], token.ticker, tokenAmount, account ? account.address : null, signAndSubmitTransaction);

	const changeAmount = (e) => {
		setTokenAmount(e.target.value);
	}

	function formatNumber(value) {
        if(value == null){
            return "0";
        }
        if (value >= 1_000_000_000) {
            return (value / 1_000_000_000).toFixed(2) + 'B';
        }else
        if (value >= 1_000_000) {
            return (value / 1_000_000).toFixed(2) + 'M';
        } else if (value >= 1_000) {
            return (value / 1_000).toFixed(2) + 'K';
        } else {
            return value.toFixed(2).toString();
        }
    }

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

	function Info(props){
		return (
			<div className="info">
				<div className="leftInfo">
					{props.leftInfo}
				</div>
				<div className="rightInfo">
					{props.rightInfo}
				</div>
			</div>
		)
	}

	return (
		<>
			{contextHolder}
			<Modal
			open={isModalOpen}
			footer={null}
			onCancel={() => setIsModalOpen(false)}
			title="Select a token"
			className="appModal"
			>
				<div className="modalContent">
				{tokenList?.map((e, i) => {
					return (
					<div
						className="tokenChoice"
						key={i}
						onClick={() => {setToken(e); setIsModalOpen(false)}}
					>
						<img src={e.img} alt={e.ticker} className="tokenLogo" />
						<div className="tokenChoiceNames">
						<div className="tokenName">{e.name}</div>
						<div className="tokenTicker">{e.ticker}</div>
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
								Successfully {pastTabs[selectedTab]}
							</div>
							</>
						}

						{transactionStatus != "successful" && 
							<>
								<img src={Failed} width="25%" style={{marginTop: "1em"}}></img>
								<div style={{fontSize: "larger", fontWeight: 'bold', fontFamily: "Montserrat"}}>
									{tabs[selectedTab]} failed
								</div>
							</>
						}

							<div style={{justifyContent: 'center', alignItems: 'center'}}>
								<div style={{display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '0.5em'}}>
										<div style={{fontFamily: "Kanit", fontSize: 48, lineHeight: "48px"}}>
											{tokenAmount}
										</div>
										<img src={token.img} height="40"></img>
										<div style={{display: 'flex', flexDirection: 'column', fontWeight: 'bold'}}>
											<div>
												{token.name}
											</div>
											<div style={{color: '#787f94'}}>
												{token.ticker}
											</div>
										</div>

								</div>
							</div>
					
						

						

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

			{isOpen == true &&
			<div style={{display: 'flex', flexDirection: 'column'}}>
				{/* <div style={{width: '100%'}} align="left">
					123
				</div> */}
				
				<div className="tradeBox">
					<div className="tradeBoxHeader">
					<div className="tab-container" style={{marginBottom: '1em'}}>
						<div className="tabs">
							{tabs.map((tab, index) => (
							<div
								key={index}
								className={`tab ${selectedTab === index ? 'active' : ''}`}
								onClick={() => changeTab(index)}
								ref={(el) => (tabRefs.current[index] = el)}
								style={{fontWeight: 'bold', fontSize: '1em', marginTop: '1em'}}
							>
								{tab}
							</div>
							))}
							<div
							className="underline"
							style={underlineStyle}
							/>
						</div>
						</div>
					</div>
					<div className="inputs">
						<Input
							placeholder="0"
							style={{fontFamily: 'Kanit'}}
							value={tokenAmount}
							onChange={changeAmount}
						/>
						<div className="assetOne" onClick={() => setIsModalOpen(true)}>
							<img src={token.img} alt="assetOneLogo" className="assetLogo" />
							{token.ticker}
							<svg fill="none" height="7" width="14" xmlns="http://www.w3.org/2000/svg"><title>Dropdown</title><path d="M12.75 1.54001L8.51647 5.0038C7.77974 5.60658 6.72026 5.60658 5.98352 5.0038L1.75 1.54001" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" xmlns="http://www.w3.org/2000/svg"></path></svg>

						</div>
					</div>
					<div className="infoContainer">
						{selectedTab == 0 &&
							<Info leftInfo="In Wallet" rightInfo={account && accountData ? parseFloat(accountData['balance_by_ticker'][token.ticker].toFixed(6)) : null}/>
							// Supply
						}
						{selectedTab == 1 &&
							<Info leftInfo="Supplied" rightInfo={account && accountData && accountData.positions.supply[token.ticker] ? parseFloat(accountData.positions.supply[token.ticker].amount.toFixed(6)) : 0}/>
							// Supply
						}
						{selectedTab == 2 &&
							<Info leftInfo="Max Borrowable" rightInfo={account && accountData && marketData ? parseFloat((accountData['borrowable'] / marketData[token.ticker].price).toFixed(6)) : null}/>
							// Borrow
						}
						{selectedTab == 3 &&
							<Info leftInfo="Borrowed" rightInfo={account && accountData && accountData.positions.borrow[token.ticker] ? parseFloat(accountData.positions.borrow[token.ticker].amount.toFixed(6)) : 0}/>
							// Supply
						}
						{(selectedTab <= 1) &&
						<Info leftInfo="Supply APY" rightInfo={marketData ? [marketData[token.ticker].deposit_apy, '%'].join('') : "-"}/>
						}
						{(selectedTab >= 2) &&
						<Info leftInfo="Borrow APY" rightInfo={marketData ? [marketData[token.ticker].borrow_apy, '%'].join('') : "-"}/>
						}

						<Info leftInfo="P2P APY" rightInfo={marketData ? [marketData[token.ticker].p2p_apy, '%'].join('') : "-"}/>
					</div>
					<div className="migrateButton" disabled={!tokenAmount} onClick={() => execute()}>{tabs[selectedTab]}</div>
				</div>
			</div>
			}

			{isOpen == false && 
			<div style={{display: 'flex', flexDirection: 'column'}}>
				<div style={{width: '80vw'}}>
					<div className="infoBox">
						<DataBox name='Total collateral' loaded={marketData != null} boxContent={`$${marketData ?  formatNumber(marketData['total_supplied']) : null}`}></DataBox>
						<DataBox name='Total loan' loaded={marketData != null}  boxContent={`$${marketData ?  formatNumber(marketData['total_borrowed']) : null}`}></DataBox>
						<DataBox name='Underlying pool' loaded={marketData != null}  boxContent={market.market}></DataBox>
					</div>
				</div>
				<div className="dashboard-container">
					<div className="marketBox">
						<div className="boxDescription">
							Supply Markets
						</div>
						<TableContainer component={Paper} style={{marginBottom: '1em'}}>
						<Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
							<TableHead >
								<TableRow >
									<TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724', width: '33%'}} align="left">Assets</TableCell>
									<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724', width: '33%'}} align="left">Wallet</TableCell>
									<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">APY</TableCell>
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
								className="marketRow"
								onClick={() => {setIsOpen(true); setToken(token); changeTab(0)}}
								>
									<TableCell style={{borderTopLeftRadius: '10px',
										borderBottomLeftRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} component="th" scope="row">
										<div style={{display: 'flex', gap: '5px'}}>
											<img src={token.img} alt={token.ticker} className='tokenLogo'></img>
											{token.ticker}
										</div>
									</TableCell>
									<TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">{(marketData && accountData) ?
											<>{accountData['balance'][index]}</> :
											!account ? <>-</>
											:
											<><Skeleton.Input
											active
											style={{
											margin: -6,
											}}
										/></>
										} </TableCell>
									<TableCell style={{borderTopRightRadius: '10px',
										borderBottomRightRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">
										{(marketData && (accountData || !account)) ?
											<>{marketData[token.ticker]['deposit_apy']}%</> :
											<><Skeleton.Input
											active
											style={{
											margin: -6,
											}}
										/></>
										}
									</TableCell>
								</TableRow>
							))}
							</TableBody>
						</Table>
						</TableContainer>

					</div>
					<div className="apyBox">
					<TableContainer component={Paper} style={{marginBottom: '1em'}}>
						<Table  aria-label="simple table">
							<TableHead>
								<TableRow>
									<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="center">P2P APY</TableCell>
								</TableRow>
							</TableHead>
							<TableBody>
							{tokenList.map((token) => (
								<TableRow
								key={token.name}
								sx={{ 'th': { border: 0 } }}
								>
									<TableCell className="selected-row" style={{fontFamily: 'Kanit', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} component="th" scope="row" align="center">
										{marketData && 
										<ShiningText isSelected={true} text={`${marketData[token.ticker]['p2p_apy']}%`}></ShiningText>
										
										}
										{(!marketData || (!accountData && account)) && <><Skeleton.Node
											active
											style={{
											margin: -6,
											width: 100,
											height: 32,
											}}
										/></>}
									</TableCell>
								</TableRow>
							))}
							</TableBody>
						</Table>
						</TableContainer>
					</div>
					<div className="marketBox">
						<div className="boxDescription">
							Borrow Markets
						</div>
						<TableContainer component={Paper} style={{marginBottom: '1em', textAlign: 'right'}}>
						<Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
							<TableHead >
								<TableRow>
									<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724', width: '33%', }} align="left">APY</TableCell>
									<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724', width: '33%'}} align="left">Liquidity</TableCell>
									<TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
								</TableRow>
							</TableHead>
							<TableBody>
							{tokenList.map((token) => (
								<TableRow
								key={token.name}
								sx= {{ 'td': { border: 0 }, 'th': { border: 0 }, '&:hover': {
										backgroundColor: '#363e54', 	
									}, backgroundColor: '#131724', 
									transition: 'background-color 0.3s ease'
								}}
								className="marketRow"
								onClick={() => {setIsOpen(true); setToken(token); changeTab(2)}}
								>
									<TableCell style={{borderTopLeftRadius: '10px',
										borderBottomLeftRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">
											{marketData && (accountData || !account) ?
												<>{marketData[token.ticker]['borrow_apy']}%</> :
												<><Skeleton.Input
											active
											style={{
											margin: -6,
											}}
										/></>
											}
										</TableCell>
									<TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">
										{marketData && (accountData || !account) ?
													<>{marketData[token.ticker]['market_liquidity']}</> :
													<><Skeleton.Input
											active
											style={{
											margin: -6,
											}}
										/></>
										}
									</TableCell>
									<TableCell style={{ borderTopRightRadius: '10px',
										borderBottomRightRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} component="th" scope="row">
										<div style={{display: 'flex', gap: '5px'}}>
											<img src={token.img} alt={token.ticker} className='tokenLogo'></img>
											{token.ticker}
										</div>
									</TableCell>
								</TableRow>
							))}
							</TableBody>
						</Table>
						</TableContainer>
					</div>
				</div>
			</div>

			}

		</>
	);
}

export default Markets;

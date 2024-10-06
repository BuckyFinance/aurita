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
import { useLocation } from "react-router-dom";
import { useMarkets } from "../hooks/useMarkets";
import { useMarketAction } from "../hooks/useWriteTx";

function Markets(props) {
	const market = props.market;
	const marketData = props.marketData;

	const [isOpen, setIsOpen] = useState(false);
	const [isModalOpen, setIsModalOpen] = useState(false);
	const [token, setToken] = useState(tokenList[0]);

	const [selectedTab, setSelectedTab] = useState(0);
	const tabRefs = useRef([]);
	const [underlineStyle, setUnderlineStyle] = useState({ width: 0, transform: 'translateX(0px)' });

	const location = useLocation();
    const { account, signAndSubmitTransaction } = useWallet();
	const [tokenAmount, setTokenAmount] = useState(null);
	
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
			setUnderlineStyle({
				width: tabElement.offsetWidth,
				transform: `translateX(${tabElement.offsetLeft}px)`
			});
		}
	}, [isOpen]);
	
	const tabs = ['Supply', 'Withdraw', 'Borrow', 'Repay'];
	
	const changeTab = (tabIndex) => {
		setSelectedTab(tabIndex);
	};
	const {isPending, isSuccess, isFailed, execute} = useMarketAction(market.id, tabs[selectedTab], token.ticker, tokenAmount, account ? account.address : null, signAndSubmitTransaction);

	const changeAmount = (e) => {
		setTokenAmount(e.target.value);
	}

	return (
			<>
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
						<div className="info">
							<div className="leftInfo">
								APY
							</div>
							<div className="rightInfo">
								56.33%
							</div>
						</div>

						<div className="info">
							<div className="leftInfo">
								P2P APY
							</div>
							<div className="rightInfo">
								123.32%
							</div>
						</div>
					</div>
					<div className="migrateButton" onClick={() => execute()}>{tabs[selectedTab]}</div>
				</div>
			</div>
			}
			{isOpen == false && 
			<div className="dashboard-container">
				<div className="marketBox">
					<div className="boxDescription">
						Supply Markets
					</div>
					<TableContainer component={Paper}>
					<Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
						<TableHead >
							<TableRow >
								<TableCell style={{fontFamily: 'Montserrat', border: 'none', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Assets</TableCell>
								<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Wallet</TableCell>
								<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">APY</TableCell>
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
							onClick={() => {setIsOpen(true); setToken(token); changeTab(0)}}
							>
								<TableCell style={{borderTopLeftRadius: '10px',
									borderBottomLeftRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} component="th" scope="row">
									<div style={{display: 'flex', gap: '5px'}}>
										<img src={token.img} alt={token.ticker} className='tokenLogo'></img>
										{token.ticker}
									</div>
								</TableCell>
								<TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">100.00</TableCell>
								<TableCell style={{borderTopRightRadius: '10px',
									borderBottomRightRadius: '10px',fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">
									{marketData ?
										<>{marketData[token.ticker]['deposit_apy']}%</> :
										<>"Loading"</>
									}
								</TableCell>
							</TableRow>
						))}
						</TableBody>
					</Table>
					</TableContainer>

				</div>
				<div className="apyBox">
				<TableContainer component={Paper}>
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
								<TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} component="th" scope="row" align="center">
									100.00%
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
					<TableContainer component={Paper}>
					<Table  aria-label="simple table" sx = {{backgroundColor: '#131724', borderRadius: 0}}>
						<TableHead >
							<TableRow>
								<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">APY</TableCell>
								<TableCell style={{fontFamily: 'Montserrat', border: 'none',fontSize: 16, color: 'white', fontWeight: 'bold', background: '#131724'}} align="left">Liquidity</TableCell>
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
										{marketData ?
											<>{marketData[token.ticker]['borrow_apy']}%</> :
											<>"Loading"</>
										}
									</TableCell>
								<TableCell style={{fontFamily: 'Kanit', fontSize: 16, color: 'white'}} align="left">
									{marketData ?
												<>{marketData[token.ticker]['market_liquidity']}</> :
												<>"Loading"</>
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
			}

		</>
	);
}

export default Markets;

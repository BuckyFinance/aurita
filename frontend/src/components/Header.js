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


function Header(props) {

  	const {address, isConnected, connect} = props;
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

	return (
		<header className="header">
				<Modal
					open={isModalOpen}
					footer={null}
					onCancel={() => setIsModalOpen(false)}
					title="Select Underlying Pool"
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
							
							{market.market == e.market && 
								<div style={{marginRight: '2em', fontSize: '1.5em', gap: '10px', display: 'flex', flexDirection: 'row', alignItems: 'center'}}>
									<div>
										Current
									</div>
									<span style={{marginBottom: '3px'}}>
										<svg height="10" width="10" xmlns="http://www.w3.org/2000/svg">
											<circle r="5" cx="5" cy="5" fill="rgb(48, 224, 0)" />
										</svg>
									</span>
								</div>
							}
						</div>
						);
					})}
					</div>
				</Modal>
				<div className="leftH">
					<div style={{gap: "5px", display: "flex", flexDirection: "row"}}>
						{/* <span style={{display: "flex", flexDirection: "column", justifyContent: "center", fontFamily: "Bellagia Display", fontSize: "larger"}}>
							AURITA
						</span> */}
						<img src={Logo} alt="logo" className="logo" />
						</div>
				<Link to="/app" className="link">
					<div className="headerItem">Dashboard</div>
				</Link>
				<Link to="/app/markets" className="link">
					<div className="headerItem">Markets</div>
				</Link>
				<Link to="/app/migrate" className="link">
					<div className="headerItem">Migrate</div>
				</Link>
				{/* <Link to="/tokens" className="link">
					<div className="headerItem">Tokens</div>
				</Link> */}
				</div>
				<div className="rightH">
				{/* <div className="headerItem">
					<img src={Eth} alt="eth" className="eth" />
					Ethereum
				</div>
				<div className="connectButton" onClick={connect}>
					{isConnected ? (address.slice(0,4) +"..." +address.slice(38)) : "Connect"}
				</div> */}
				<div className="wallet-button" onClick={() => setIsModalOpen(true)}>
					<div style={{display: 'flex', flexDirection: 'row', gap: '7px', justifyContent: 'center', alignItems: 'center'}}>
						<img src={market.img} height={24}></img>	
						<div>
							{market.market}
						</div>
						<svg fill="none" height="7" width="14" xmlns="http://www.w3.org/2000/svg"><title>Dropdown</title><path d="M12.75 1.54001L8.51647 5.0038C7.77974 5.60658 6.72026 5.60658 5.98352 5.0038L1.75 1.54001" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" xmlns="http://www.w3.org/2000/svg"></path></svg>
					</div>
				</div>
				<Col span={12} style={{ textAlign: "right", paddingRight: "50px" }}>
					<WalletSelector />
				</Col>
				</div>
		</header>
	);
}

export default Header;

import "./App.css";
import Header from "./components/Header";
import Markets from "./components/Markets";
import Tokens from "./components/Tokens";
import { Routes, Route } from "react-router-dom";
import { useConnect, useAccount } from "wagmi";
import { MetaMaskConnector } from "wagmi/connectors/metaMask";
import { useEffect, useState } from "react";
import Dashboard from "./components/Dashboard";
import Loading from "./components/Loading";
import Landing from "./components/Landing";
import Aurita from "./components/Aurita";

import { Aptos, AptosConfig} from "@aptos-labs/ts-sdk";
import { Network } from "aptos";


const aptosConfig = new AptosConfig({network: Network.TESTNET});
export const aptos = new Aptos(aptosConfig);
export const moduleAriesMarket = "0xf55e848e77a859764141c59d9c72664bd8e4adc048f6fc0e73df885a89ef2576";
export const moduleEchelonMarket = "0x58e4568f9411d6137bdcdf4663f4b107ea4157813fadeb2b1e14492c917d59c0";
export const moduleAuritaCoin = "0xc216e8072f3d64c67324680b229f1c5ade5eaa173e9412f580f804067aa4be8b";


function App() {
	const { address, isConnected } = useAccount();
	const { connect } = useConnect({
		connector: new MetaMaskConnector(),
	});


	return (
		<Routes>
			<Route path="/" element={<Landing />}></Route>
			<Route path="/app/*" element={<Aurita />}></Route>
		</Routes>
	)
}

export default App;

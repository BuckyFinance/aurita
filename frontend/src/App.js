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
export const moduleAriesMarket = "0x13a95507bbb7f53a3d0409971a6188285cc56a8d99877e1ea29ad88acc442da8";
export const moduleEchelonMarket = "0xe067195ef0b7bea0dceac76abe2e594859f93eb6f1ce44f2bdc156687f350b23";
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

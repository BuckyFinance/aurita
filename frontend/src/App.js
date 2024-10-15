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
export const moduleAriesMarket = "0xfa84857baea2193a1be537e8e2f00b83aa0e344190422728149dfb2b8b53a793";
export const moduleEchelonMarket = "0xa171ea688997f5ef015cd14e7d481ef69153596da555d6e6f3a4bda153004dca";
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

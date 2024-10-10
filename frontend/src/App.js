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
export const moduleAriesMarket = "0x69a668919f0081415a0f5576494839245619a24c5f34d0ed3d234ddd9939ed6f";
export const moduleEchelonMarket = "0x6afef8ac2f7f908a684477ab24b1ff8a91e5ab6f2148e2c8c7ae43f0da0ae654";
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

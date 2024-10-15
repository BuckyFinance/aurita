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
export const moduleAriesMarket = "0xd6b595c3aad4f347c0d5fc8a6a0388650ec03f8a83958ca7fbba36d4d6cd96f3";
export const moduleEchelonMarket = "0xe8de41b038fd1482380a51eabf4d16e443011e855275825c3963e8958f43d5d8";
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

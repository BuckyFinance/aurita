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

import { Aptos } from "@aptos-labs/ts-sdk";
export const aptos = new Aptos();
export const moduleAriesMarket = "0x9584e021c09cd15a1c6ae2781734bc7c305f7cbcb478fec1d511a5688f75061f";
export const moduleEchelonMarket = "0xaad8bcdc1af90b827eba61c5664e07958166656fa4a10cf7ae4129983ca6b0a4";


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

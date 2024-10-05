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
export const moduleAriesMarket = "0xd078a8ba11c56a0a29b321016aecee134cc503e6bd21a6c98da5130bd38bdc82";
export const moduleEchelonMarket = "0xc1c26ae676ef6cdda408a27bff9b6c48b532102898699691ae1c19bc17783432";


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

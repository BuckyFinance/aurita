import "./../App.css";
import Header from "./Header";
import Markets from "./Markets";
import { Routes, Route } from "react-router-dom";
import { useEffect, useState} from "react";
import Dashboard from "./Dashboard";
import Loading from "./Loading";
import Landing from "./Landing";
import Migrate from "./Migrate"
import Aries from "./../media/aries.png"
import Echelon from "./../media/echelon.png"
import { useMarkets } from "../hooks/useMarkets";

export const marketList = [
	{
		"market": "Aries",
		"img": Aries,
		"id": 0,
	}, 
	{
		"market": "Echelon",
		"img": Echelon,
		"id": 1,
	}
];

function Aurita(){
    const [loading, setLoading] = useState(true);
	const [fading, setFading] = useState(false);

    const [market, setMarket] = useState(marketList[0]);
	const {marketData} = useMarkets(market.id);

	useEffect(() => {
		const timer = setTimeout(() => {
			setLoading(false);
		}, 500); 
		return () => clearTimeout(timer);
	}, []);
	
	useEffect(() => {
		const timer = setTimeout(() => {
			console.log("start loading");
			setFading(true);
		}, 1);
		return () => clearTimeout(timer);
	}, []);

    return (
        <div className="App">
		{loading &&
        (	
            <div className={`loading-screen ${!fading  ? 'fade-in' : 'fade-out'}`}>
                <Loading/>
                </div>
        )}
        
        {fading	&& (
                <>
                <Header market={market} setMarket={setMarket} />
                <div className="mainWindow">
                    
                    <Routes>
                        <Route path="/" element={<Dashboard market={market}/>}></Route>
                        <Route path="/markets" element={<Markets market={market} marketData={marketData} />} />
                        <Route path="/migrate" element={<Migrate market={market}/>} />
                    </Routes>
                </div>
                </>
            )
        }
        </div>
    )
}

export default Aurita;
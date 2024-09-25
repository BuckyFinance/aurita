import "./../App.css";
import Header from "./Header";
import Markets from "./Markets";
import { Routes, Route } from "react-router-dom";
import { useEffect, useState} from "react";
import Dashboard from "./Dashboard";
import Loading from "./Loading";
import Landing from "./Landing";
import Migrate from "./Migrate"


function Aurita(){
    const [loading, setLoading] = useState(true);
	const [fading, setFading] = useState(false);

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
                <Header />
                <div className="mainWindow">
                    
                    <Routes>
                        <Route path="/" element={<Dashboard/>}></Route>
                        <Route path="/markets" element={<Markets />} />
                        <Route path="/migrate" element={<Migrate />} />
                    </Routes>
                </div>
                </>
            )
        }
        </div>
    )
}

export default Aurita;
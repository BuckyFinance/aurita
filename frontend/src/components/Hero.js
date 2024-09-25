// import React from 'react';
// import Particles from 'react-tsparticles';
// import { loadSlim } from 'tsparticles-slim';

// const Hero = () => {
//   const particlesInit = async (main) => {
//     await loadSlim(main);
//   };

//   const particlesLoaded = (container) => {
//   };

//   return (
//     <div className="hero">
//       <Particles
//         id="tsparticles"
//         init={particlesInit}
//         loaded={particlesLoaded}
//         options={{
//           background: {
//             color: {
//               value: 'rgb(25, 33, 52)',
//             },
//           },
//           fpsLimit: 60,
//           interactivity: {
//             events: {
//               onHover: {
//                 enable: true,
//                 mode: 'grab',
//               },
//               resize: true,
//             },
//             modes: {
//               grab: {
//                 distance: 200,
//                 links: {
//                   opacity: 0.7,
//                 },
//               },
//             },
//           },
//           particles: {
//             color: {
//               value: ['#55688A', '#8799B8', '#DCE3EB'],
//             },
//             links: {
//               color: '#55688A',
//               distance: 150,
//               enable: true,
//               opacity: 0.3,
//               width: 1,
//             },
//             move: {
//               direction: 'none',
//               enable: true,
//               outModes: {
//                 default: 'out',
//               },
//               random: false,
//               speed: 2,
//               straight: false,
//             },
//             number: {
//               density: {
//                 enable: true,
//                 area: 800,
//               },
//               value: 60,
//             },
//             opacity: {
//               value: 0.5,
//               random: true,
//             },
//             shape: {
//               type: 'circle',
//             },
//             size: {
//               value: 3,
//               random: true,
//             },
//           },
//           detectRetina: true,
//         }}
//       />

//       {/* Content overlay */}
//       <div className="hero-content">
//         <h1>Pay Less, Earn More</h1>
//         <p>
//           Connect directly with borrowers and lenders worldwide for optimal
//           returns. No intermediaries, no hidden fees.
//         </p>
//         <a href="/app" className="cta-button">
//             Launch App
//         </a>
//       </div>
//     </div>
//   );
// };

// export default Hero;


// DarkOceanBackground.js
// DarkOceanBackground.js
import React, { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import jellyfish from "../media/jellyfish.png"

const DarkOceanBackground = () => {
  const particleContainerRef = useRef(null);
  const navigate = useNavigate();
  const [fadeOut, setFadeOut] = useState(false); // State to trigger fade out

  useEffect(() => {
    const numParticles = 200;
    const particleContainer = particleContainerRef.current;

    const particles = [];

    for (let i = 0; i < numParticles; i++) {
      const particle = document.createElement('div');
      particle.classList.add('particle');

      // Random size between 1px and 4px
      const size = Math.random() * 5 + 2;
      particle.style.width = `${size}px`;
      particle.style.height = `${size}px`;

      // Random horizontal position
      particle.style.left = `${Math.random() * 100}%`;

      // Random animation duration between 5s and 15s
      const duration = Math.random() * 10 + 5;
      particle.style.animationDuration = `${duration}s`;

      // Random animation delay to stagger particle animations
      particle.style.animationDelay = `${Math.random() * -20}s`;

      particleContainer.appendChild(particle);
      particles.push(particle);
    }

    // Cleanup function to remove particles on unmount
    return () => {
      particles.forEach((particle) => {
        particleContainer.removeChild(particle);
      });
    };
  }, []);

  const handleLaunchAppClick = () => {
    // Start fade-out animations
    setFadeOut(true);

    // Wait for animations to finish before redirecting
    setTimeout(() => {
		navigate('/app');
    }, 1000); // 500ms to match the transition duration
  };

  return (
    <div className="landing-container">
      <div
        id="particle-container"
        ref={particleContainerRef}
        className={fadeOut ? 'particle-fade-out' : ''}
      ></div>
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        <div
          className={`landing-text ${fadeOut ? 'fade-move-out' : 'fade-move-in'}`}
          style={{ display: 'flex', flexDirection: 'row', justifyContent: 'center' }}
        >
          <div style={{ display: 'flex', flexDirection: 'column', alignContent: 'center', justifyContent: 'center' }}>
            <div className="fade-move-in">
              <div className="myObject">
                <img
                  style={{ height: '80vh' }}
                  src={jellyfish}
                />
              </div>
            </div>
          </div>
          <div
            className={`fade-move-in2 ${fadeOut ? 'fade-move-out2' : ''}`}
            style={{ display: 'flex', flexDirection: 'column', alignContent: 'center', justifyContent: 'center' }}
          >
            <div style={{ fontFamily: 'Bellagia Display', fontSize: '10em' }}>AURITA</div>
            <div style={{ fontFamily: 'Bellagia Display', fontSize: '2em' }}>
              The Premier Money Market Optimizer on Aptos
            </div>
          </div>
        </div>
        <div className={`fade-move-in3 ${fadeOut ? 'fade-move-out3' : ''}`} style={{ display: 'flex', justifyContent: 'center' }}>
          <button className="launch-app-button" onClick={handleLaunchAppClick}>
            <span className="text">Launch App</span>
            <span className="glow glow1">Launch App</span>
            <span className="glow glow2">Launch App</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default DarkOceanBackground;

import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';

const ShiningText = ({ text, isSelected }) => {
  const [stars, setStars] = useState([]);

  useEffect(() => {
    if (isSelected) {
      const numStars = 10;
      const newStars = [];

      for (let i = 0; i < numStars; i++) {
        const size = Math.floor(Math.random() * 4) + 10;
        const top = Math.floor(Math.random() * 80);
        const left = Math.floor(Math.random() * 100);
        const delay = (Math.random() * 5).toFixed(2);
        const zIndex = Math.random() < 0.5 ? -1 : 1;
        const rotation = Math.floor(Math.random() * 361);

        newStars.push({
          id: i,
          size,
          top,
          left,
          delay,
          zIndex,
          rotation,
        });
      }

      setStars(newStars);
    } else {
      setStars([]);
    }
  }, [isSelected]);

  return (
    <div className={`shining-text ${!isSelected ? 'not-selected' : ''}`}>
      {text}
      {stars.map((star) => (
        <div
          key={star.id}
          className="star"
          style={{
            width: `${star.size}px`,
            height: `${star.size}px`,
            top: `${star.top}%`,
            left: `${star.left}%`,
            animationDelay: `${star.delay}s`,
            zIndex: star.zIndex,
            '--star-rotation': `${star.rotation}deg`,
          }}
        ></div>
      ))}
    </div>
  );
};

ShiningText.propTypes = {
  text: PropTypes.string.isRequired,
  isSelected: PropTypes.bool,
};

ShiningText.defaultProps = {
  isSelected: true,
};

export default ShiningText;

import React, { useState } from 'react';
import styled from 'styled-components';

const Container = styled.div`
  background: rgba(20,20,20,0.95);
  padding: 20px;
  border-radius: 8px;
  max-width: 500px;
  margin: 50px auto;
  text-align: center;
`;

const Stars = styled.div`
  margin: 20px 0;
  button {
    background: none;
    border: none;
    font-size: 2rem;
    color: ${props => props.selected ? '#FFD700' : '#444'};
    cursor: pointer;
    &:hover {
      color: #FFD700;
    }
  }
`;

function RatingUI({ maxRating, sendUIAction }) {
  const [rating, setRating] = useState(0);

  const submitRating = () => {
    sendUIAction('ratePerformance', { rating });
  };

  return (
    <Container>
      <h1>Rate Your Performance</h1>
      <Stars>
        {Array.from({ length: maxRating }, (_, i) => (
          <button key={i} onClick={() => setRating(i + 1)}>
            {i < rating ? '★' : '☆'}
          </button>
        ))}
      </Stars>
      <button onClick={submitRating}>Submit Rating</button>
    </Container>
  );
}

export default RatingUI;

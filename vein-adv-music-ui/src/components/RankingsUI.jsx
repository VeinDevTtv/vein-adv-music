import React, { useEffect, useState } from 'react';
import styled from 'styled-components';

const Container = styled.div`
  background: rgba(20,20,20,0.95);
  padding: 20px;
  border-radius: 8px;
  max-width: 600px;
  margin: 50px auto;
  text-align: center;
`;

function RankingsUI({ sendUIAction }) {
  const [rankings, setRankings] = useState([]);

  useEffect(() => {
    // Replace this with a real API call to your server/database
    setTimeout(() => {
      setRankings([
        { rank: 1, name: 'DJ Alpha', score: 95 },
        { rank: 2, name: 'MC Bravo', score: 90 },
        { rank: 3, name: 'Band Charlie', score: 85 },
      ]);
    }, 1000);
  }, []);

  return (
    <Container>
      <h1>Live Artist Rankings</h1>
      <ul>
        {rankings.map((artist) => (
          <li key={artist.rank}>
            {artist.rank}. {artist.name} - Score: {artist.score}
          </li>
        ))}
      </ul>
      <button onClick={() => sendUIAction('refreshRankings', {})}>Refresh Rankings</button>
    </Container>
  );
}

export default RankingsUI;

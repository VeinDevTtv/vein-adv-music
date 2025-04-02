import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  background: rgba(20,20,20,0.95);
  padding: 20px;
  border-radius: 8px;
  max-width: 600px;
  margin: 50px auto;
  text-align: center;
`;

function MusicAwardsUI({ sendUIAction }) {
  return (
    <Container>
      <h1>Music Awards</h1>
      <p>Vote for Best Artist and Best Song!</p>
      <button onClick={() => sendUIAction('voteBestArtist', {})}>Vote Best Artist</button>
      <button onClick={() => sendUIAction('voteBestSong', {})}>Vote Best Song</button>
    </Container>
  );
}

export default MusicAwardsUI;

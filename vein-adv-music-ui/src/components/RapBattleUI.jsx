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

function RapBattleUI({ initiator, sendUIAction }) {
  return (
    <Container>
      <h1>Rap Battle</h1>
      <p>Initiated by: {initiator}</p>
      <p>Let the crowd vote!</p>
      <button onClick={() => sendUIAction('voteRapBattle', { vote: 'winner' })}>
        Vote Winner
      </button>
    </Container>
  );
}

export default RapBattleUI;

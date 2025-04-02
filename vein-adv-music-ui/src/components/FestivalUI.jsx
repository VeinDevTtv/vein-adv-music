import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  background: rgba(20,20,20,0.95);
  padding: 20px;
  border-radius: 8px;
  max-width: 800px;
  margin: 50px auto;
  text-align: center;
`;

function FestivalUI({ sendUIAction }) {
  return (
    <Container>
      <h1>Virtual Festival</h1>
      <p>Enjoy multiple stages and live performances!</p>
      <button onClick={() => sendUIAction('joinStage', { stage: 'Main Stage' })}>
        Join Main Stage
      </button>
    </Container>
  );
}

export default FestivalUI;

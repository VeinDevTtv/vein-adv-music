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

function TalkShowUI({ host, sendUIAction }) {
  return (
    <Container>
      <h1>Live Talk Show</h1>
      <p>Host: {host}</p>
      <p>Interact with your guests!</p>
      <button onClick={() => sendUIAction('askQuestion', { question: 'What\'s your favorite song?' })}>
        Ask Question
      </button>
    </Container>
  );
}

export default TalkShowUI;

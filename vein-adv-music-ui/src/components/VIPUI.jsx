import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  background: rgba(20,20,20,0.95);
  padding: 20px;
  border-radius: 8px;
  max-width: 500px;
  margin: 50px auto;
  text-align: center;
`;

function VIPUI({ sendUIAction }) {
  return (
    <Container>
      <h1>VIP Backstage</h1>
      <p>Meet the artists behind the performance!</p>
      <button onClick={() => sendUIAction('chatVIP', {})}>Start Chat</button>
    </Container>
  );
}

export default VIPUI;

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

const Controls = styled.div`
  margin-top: 20px;
  button {
    margin: 10px;
    padding: 12px 24px;
    background: #1db954;
    border: none;
    border-radius: 4px;
    color: #fff;
    font-size: 1rem;
    transition: background 0.3s;
    &:hover {
      background: #17a74a;
    }
  }
`;

function DJUI({ sendUIAction }) {
  return (
    <Container>
      <h1>DJ Turntable</h1>
      <Controls>
        <button onClick={() => sendUIAction('djMix', {})}>Start Mixing</button>
        <button onClick={() => sendUIAction('djMix', { effect: 'crossfade' })}>Crossfade</button>
        <button onClick={() => sendUIAction('djMix', { effect: 'boost' })}>Boost Bass</button>
      </Controls>
    </Container>
  );
}

export default DJUI;

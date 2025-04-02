import React, { useEffect, useState } from 'react';
import PerformanceUI from './components/PerformanceUI';
import RatingUI from './components/RatingUI';
import DJUI from './components/DJUI';
import RapBattleUI from './components/RapBattleUI';
import TalkShowUI from './components/TalkShowUI';
import FestivalUI from './components/FestivalUI';
import VIPUI from './components/VIPUI';
import RankingsUI from './components/RankingsUI';
import MusicAwardsUI from './components/MusicAwardsUI';
import styled from 'styled-components';

const AppContainer = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  pointer-events: none;
`;

const ErrorMessage = styled.div`
  background: rgba(255, 0, 0, 0.8);
  color: white;
  padding: 10px 20px;
  border-radius: 5px;
  margin: 10px;
  pointer-events: auto;
`;

const LoadingSpinner = styled.div`
  border: 4px solid rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  border-top: 4px solid #fff;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
`;

function App() {
  const [uiState, setUiState] = useState({ current: 'idle', payload: {} });
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    const handleMessage = (event) => {
      const data = event.data;
      if (data.action) {
        setUiState({ current: data.action, payload: data });
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  const sendUIAction = async (action, payload) => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await fetch(`https://${GetParentResourceName()}/uiAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ action, ...payload }),
      });

      if (!response.ok) {
        throw new Error('Failed to send UI action');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const renderUI = () => {
    if (isLoading) {
      return <LoadingSpinner />;
    }

    switch (uiState.current) {
      case 'openPerformanceUI':
        return <PerformanceUI trackUrl={uiState.payload.trackUrl} sendUIAction={sendUIAction} />;
      case 'openRatingUI':
        return <RatingUI maxRating={uiState.payload.maxRating} sendUIAction={sendUIAction} />;
      case 'openDJUI':
        return <DJUI sendUIAction={sendUIAction} />;
      case 'startRapBattle':
        return <RapBattleUI initiator={uiState.payload.initiator} sendUIAction={sendUIAction} />;
      case 'startTalkShow':
        return <TalkShowUI host={uiState.payload.host} sendUIAction={sendUIAction} />;
      case 'festivalMode':
        return <FestivalUI sendUIAction={sendUIAction} />;
      case 'vipAccess':
        return <VIPUI sendUIAction={sendUIAction} />;
      case 'showRankings':
        return <RankingsUI sendUIAction={sendUIAction} />;
      case 'musicAwards':
        return <MusicAwardsUI sendUIAction={sendUIAction} />;
      case 'crowdReaction':
        return <div className="crowd-reaction" role="status">Crowd Reaction: {uiState.payload.reaction}</div>;
      default:
        return null;
    }
  };

  return (
    <AppContainer>
      {error && <ErrorMessage role="alert">{error}</ErrorMessage>}
      {renderUI()}
    </AppContainer>
  );
}

export default App;

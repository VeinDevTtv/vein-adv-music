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

function App() {
  const [uiState, setUiState] = useState({ current: 'idle', payload: {} });

  useEffect(() => {
    window.addEventListener('message', (event) => {
      const data = event.data;
      if (data.action) {
        setUiState({ current: data.action, payload: data });
      }
    });
  }, []);

  const sendUIAction = (action, payload) => {
    fetch(`https://${GetParentResourceName()}/uiAction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify({ action, ...payload }),
    });
  };

  const renderUI = () => {
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
        return <div className="crowd-reaction">Crowd Reaction: {uiState.payload.reaction}</div>;
      default:
        return null;
    }
  };

  return <div className="app-container">{renderUI()}</div>;
}

export default App;

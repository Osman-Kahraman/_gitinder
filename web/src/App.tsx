import { useState, useCallback } from 'react';
import { useAuth } from './hooks/useAuth';
import { useRepos } from './hooks/useRepos';
import { useStarredHistory } from './hooks/useStarredHistory';
import LoginScreen from './components/LoginScreen';
import ProfileHeader from './components/ProfileHeader';
import SwipeDeck from './components/SwipeDeck';
import ActionBar from './components/ActionBar';
import StarredDrawer from './components/StarredDrawer';
import { RefreshCw } from 'lucide-react';

export default function App() {
  const { token, user, loading: authLoading, error: authError, login, logout } = useAuth();
  const {
    currentRepo,
    nextRepo,
    peekRepo,
    swipeRight,
    swipeLeft,
    loading: reposLoading,
    empty,
    refresh,
  } = useRepos(token);

  const { history, addToHistory, clearHistory } = useStarredHistory();
  const [drawerOpen, setDrawerOpen] = useState(false);

  const handleSwipeRight = useCallback(() => {
    swipeRight(addToHistory);
  }, [swipeRight, addToHistory]);

  if (authLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-bg">
        <div className="text-accent-green font-mono text-sm animate-pulse">initializing...</div>
      </div>
    );
  }

  if (!token || !user) {
    return <LoginScreen onLogin={login} error={authError} />;
  }

  return (
    <div className="flex flex-col min-h-screen bg-bg">
      <ProfileHeader
        user={user}
        starredCount={history.length}
        onLogout={logout}
        onOpenHistory={() => setDrawerOpen(true)}
      />

      <div className="flex-1 flex flex-col items-center justify-center px-4">
        {reposLoading && !currentRepo ? (
          <div className="text-accent-green font-mono text-sm animate-pulse">
            fetching repos...
          </div>
        ) : empty && !currentRepo ? (
          <div className="flex flex-col items-center gap-4 text-center">
            <p className="text-primary font-mono text-lg">You've seen everything!</p>
            <p className="text-secondary font-mono text-sm">No more repos to show right now.</p>
            <button
              onClick={refresh}
              className="flex items-center gap-2 text-accent-green font-mono text-sm border border-accent-green rounded-lg px-4 py-2 hover:bg-accent-green/10 transition-colors cursor-pointer"
            >
              <RefreshCw size={16} />
              Refresh
            </button>
          </div>
        ) : (
          <>
            <SwipeDeck
              currentRepo={currentRepo}
              nextRepo={nextRepo}
              peekRepo={peekRepo}
              onSwipeLeft={swipeLeft}
              onSwipeRight={handleSwipeRight}
            />
            <ActionBar onSkip={swipeLeft} onStar={handleSwipeRight} />
          </>
        )}
      </div>

      <StarredDrawer
        open={drawerOpen}
        history={history}
        onClose={() => setDrawerOpen(false)}
        onClear={clearHistory}
      />
    </div>
  );
}

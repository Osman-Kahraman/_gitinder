import { useRef, useState, useCallback, useEffect } from 'react';
import TinderCard from 'react-tinder-card';
import type { Repo } from '../types/github';
import RepoCard from './RepoCard';

interface Props {
  currentRepo: Repo | null;
  nextRepo: Repo | null;
  peekRepo: Repo | null;
  onSwipeLeft: () => void;
  onSwipeRight: () => void;
}

type SwipeDir = 'left' | 'right' | 'up' | 'down';
type API = { swipe: (dir?: SwipeDir) => Promise<void>; restoreCard: () => Promise<void> };

export default function SwipeDeck({ currentRepo, nextRepo, peekRepo, onSwipeLeft, onSwipeRight }: Props) {
  const cardRef = useRef<API>(null);
  const [dragDir, setDragDir] = useState<'left' | 'right' | null>(null);

  const handleSwipe = useCallback(
    (direction: SwipeDir) => {
      setDragDir(null);
      if (direction === 'right') onSwipeRight();
      else if (direction === 'left') onSwipeLeft();
    },
    [onSwipeLeft, onSwipeRight]
  );

  const triggerSwipe = useCallback(
    (dir: 'left' | 'right') => {
      cardRef.current?.swipe(dir);
    },
    []
  );

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'ArrowLeft') triggerSwipe('left');
      if (e.key === 'ArrowRight') triggerSwipe('right');
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [triggerSwipe]);

  const cards = [peekRepo, nextRepo, currentRepo].filter(Boolean) as Repo[];

  return (
    <div className="relative w-full max-w-sm mx-auto" style={{ height: 420 }}>
      {cards.map((repo, idx) => {
        const isTop = idx === cards.length - 1;
        const offset = (cards.length - 1 - idx) * 4;
        const scale = 1 - (cards.length - 1 - idx) * 0.03;

        if (isTop) {
          return (
            <TinderCard
              ref={cardRef as React.Ref<API>}
              key={repo.id}
              onSwipe={handleSwipe}
              onSwipeRequirementFulfilled={(dir) => setDragDir(dir as 'left' | 'right')}
              onSwipeRequirementUnfulfilled={() => setDragDir(null)}
              preventSwipe={['up', 'down']}
              swipeRequirementType="position"
              swipeThreshold={80}
              className="absolute inset-0"
            >
              <RepoCard
                repo={repo}
                overlay={dragDir}
                style={{ transform: `translateY(${offset}px) scale(${scale})` }}
              />
            </TinderCard>
          );
        }

        return (
          <RepoCard
            key={repo.id}
            repo={repo}
            overlay={null}
            style={{
              transform: `translateY(${offset}px) scale(${scale})`,
              zIndex: -idx,
            }}
          />
        );
      })}

      {cards.length === 0 && (
        <div className="flex items-center justify-center h-full text-secondary font-mono text-sm">
          loading...
        </div>
      )}
    </div>
  );
}

export type { Props as SwipeDeckProps };
export { SwipeDeck };

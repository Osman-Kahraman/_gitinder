import { useState, useEffect, useCallback, useRef } from 'react';
import { getTrendingRepos, starRepo } from '../api/github';
import type { Repo } from '../types/github';

const REFETCH_THRESHOLD = 5;

export function useRepos(token: string | null) {
  const [queue, setQueue] = useState<Repo[]>([]);
  const [loading, setLoading] = useState(true);
  const [empty, setEmpty] = useState(false);
  const seenIds = useRef(new Set<number>());
  const page = useRef(1);
  const fetching = useRef(false);

  const fetchMore = useCallback(async () => {
    if (fetching.current) return;
    fetching.current = true;

    try {
      const repos = await getTrendingRepos(token ?? undefined, undefined, 'weekly', page.current);
      const fresh = repos.filter((r) => !seenIds.current.has(r.id));
      fresh.forEach((r) => seenIds.current.add(r.id));

      if (fresh.length === 0 && repos.length === 0) {
        setEmpty(true);
      } else {
        setQueue((prev) => [...prev, ...fresh]);
        page.current += 1;
      }
    } catch (err) {
      console.error('Failed to fetch repos:', err);
    } finally {
      setLoading(false);
      fetching.current = false;
    }
  }, [token]);

  useEffect(() => {
    fetchMore();
  }, [fetchMore]);

  useEffect(() => {
    if (queue.length < REFETCH_THRESHOLD && !fetching.current && !empty) {
      fetchMore();
    }
  }, [queue.length, fetchMore, empty]);

  const advance = useCallback(() => {
    setQueue((prev) => {
      const next = prev.slice(1);
      if (next.length === 0 && !fetching.current) setEmpty(true);
      return next;
    });
  }, []);

  const swipeRight = useCallback(async (onStarred?: (repo: Repo) => void) => {
    const repo = queue[0];
    if (!repo || !token) return;
    advance();
    onStarred?.(repo);
    try {
      await starRepo(repo.owner.login, repo.name, token);
    } catch (err) {
      console.error('Failed to star repo:', err);
    }
  }, [queue, token, advance]);

  const swipeLeft = useCallback(() => {
    advance();
  }, [advance]);

  const refresh = useCallback(() => {
    seenIds.current.clear();
    page.current = 1;
    setQueue([]);
    setEmpty(false);
    setLoading(true);
    fetchMore();
  }, [fetchMore]);

  const currentRepo = queue[0] ?? null;
  const nextRepo = queue[1] ?? null;
  const peekRepo = queue[2] ?? null;

  return { currentRepo, nextRepo, peekRepo, queue, swipeRight, swipeLeft, loading, empty, refresh };
}

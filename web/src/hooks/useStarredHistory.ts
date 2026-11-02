import { useState, useCallback } from 'react';
import type { Repo } from '../types/github';

interface StarredEntry {
  id: number;
  name: string;
  full_name: string;
  owner_login: string;
  owner_avatar: string;
  description: string | null;
  language: string | null;
  stargazers_count: number;
  html_url: string;
  starred_at: number;
}

const STORAGE_KEY = 'gitinder_starred_history';

function load(): StarredEntry[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function save(entries: StarredEntry[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
}

export function useStarredHistory() {
  const [history, setHistory] = useState<StarredEntry[]>(load);

  const addToHistory = useCallback((repo: Repo) => {
    const entry: StarredEntry = {
      id: repo.id,
      name: repo.name,
      full_name: repo.full_name,
      owner_login: repo.owner.login,
      owner_avatar: repo.owner.avatar_url,
      description: repo.description,
      language: repo.language,
      stargazers_count: repo.stargazers_count,
      html_url: repo.html_url,
      starred_at: Date.now(),
    };

    setHistory((prev) => {
      const next = [entry, ...prev.filter((e) => e.id !== repo.id)];
      save(next);
      return next;
    });
  }, []);

  const clearHistory = useCallback(() => {
    setHistory([]);
    localStorage.removeItem(STORAGE_KEY);
  }, []);

  return { history, addToHistory, clearHistory };
}

export type { StarredEntry };

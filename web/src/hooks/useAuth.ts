import { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import { getAuthenticatedUser } from '../api/github';
import type { User } from '../types/github';

const TOKEN_KEY = 'github_token';

export function useAuth() {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem(TOKEN_KEY));
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');

    if (code) {
      window.history.replaceState({}, '', window.location.pathname);
      exchangeCode(code);
    } else if (token) {
      fetchUser(token);
    } else {
      setLoading(false);
    }
  }, []);

  async function exchangeCode(code: string) {
    try {
      const backendUrl = import.meta.env.VITE_BACKEND_URL;
      const { data } = await axios.post(`${backendUrl}/oauth/exchange`, { code });
      const accessToken = data.access_token;
      localStorage.setItem(TOKEN_KEY, accessToken);
      setToken(accessToken);
      await fetchUser(accessToken);
    } catch {
      console.error('OAuth exchange failed');
      setLoading(false);
    }
  }

  async function fetchUser(t: string) {
    try {
      const u = await getAuthenticatedUser(t);
      setUser(u);
    } catch {
      localStorage.removeItem(TOKEN_KEY);
      setToken(null);
    } finally {
      setLoading(false);
    }
  }

  const login = useCallback(() => {
    const clientId = import.meta.env.VITE_GITHUB_CLIENT_ID;
    const redirectUri = import.meta.env.VITE_GITHUB_REDIRECT_URI;
    window.location.href =
      `https://github.com/login/oauth/authorize?client_id=${clientId}&scope=public_repo&redirect_uri=${redirectUri}`;
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem(TOKEN_KEY);
    setToken(null);
    setUser(null);
  }, []);

  return { token, user, loading, login, logout };
}

import { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import { getAuthenticatedUser } from '../api/github';
import type { User } from '../types/github';

const TOKEN_KEY = 'github_token';

function getEnvVar(name: string): string {
  const value = import.meta.env[name];
  if (!value || value.startsWith('YOUR')) {
    throw new Error(
      `Missing environment variable: ${name}. ` +
      `Copy web/.env.example to web/.env and fill in your credentials. ` +
      `See web/README.md for setup instructions.`
    );
  }
  return value;
}

export function useAuth() {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem(TOKEN_KEY));
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

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
      const backendUrl = getEnvVar('VITE_BACKEND_URL');
      const { data } = await axios.post(`${backendUrl}/oauth/exchange`, { code });
      const accessToken = data.access_token;
      if (!accessToken) {
        throw new Error('No access_token returned. Check that oauth/.env has the correct CLIENT_SECRET.');
      }
      localStorage.setItem(TOKEN_KEY, accessToken);
      setToken(accessToken);
      await fetchUser(accessToken);
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'OAuth exchange failed';
      console.error('OAuth exchange failed:', msg);
      setError(msg);
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
    try {
      const clientId = getEnvVar('VITE_GITHUB_CLIENT_ID');
      const redirectUri = getEnvVar('VITE_GITHUB_REDIRECT_URI');
      window.location.href =
        `https://github.com/login/oauth/authorize?client_id=${clientId}&scope=public_repo&redirect_uri=${redirectUri}`;
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Configuration error';
      setError(msg);
    }
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem(TOKEN_KEY);
    setToken(null);
    setUser(null);
    setError(null);
  }, []);

  return { token, user, loading, error, login, logout };
}

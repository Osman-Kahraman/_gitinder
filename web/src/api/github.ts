import axios from 'axios';
import type { Repo, User, LanguageMap } from '../types/github';

const api = axios.create({
  baseURL: 'https://api.github.com',
});

function authHeaders(token?: string) {
  if (!token) return {};
  return { Authorization: `Bearer ${token}` };
}

export async function getTrendingRepos(
  token?: string,
  language?: string,
  since: 'daily' | 'weekly' = 'daily',
  page = 1
): Promise<Repo[]> {
  const daysAgo = since === 'daily' ? 1 : 7;
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  const dateStr = date.toISOString().split('T')[0];

  let query = `stars:>100 pushed:>${dateStr}`;
  if (language) query += ` language:${language}`;

  const { data } = await api.get('/search/repositories', {
    params: {
      q: query,
      sort: 'stars',
      order: 'desc',
      per_page: 30,
      page,
    },
    headers: authHeaders(token),
  });

  return data.items;
}

export async function starRepo(owner: string, repo: string, token: string): Promise<void> {
  await api.put(`/user/starred/${owner}/${repo}`, null, {
    headers: {
      ...authHeaders(token),
      'Content-Length': '0',
    },
  });
}

export async function unstarRepo(owner: string, repo: string, token: string): Promise<void> {
  await api.delete(`/user/starred/${owner}/${repo}`, {
    headers: authHeaders(token),
  });
}

export async function getRepoLanguages(
  owner: string,
  repo: string,
  token?: string
): Promise<LanguageMap> {
  const { data } = await api.get(`/repos/${owner}/${repo}/languages`, {
    headers: authHeaders(token),
  });
  return data;
}

export async function getAuthenticatedUser(token: string): Promise<User> {
  const { data } = await api.get('/user', {
    headers: authHeaders(token),
  });
  return data;
}

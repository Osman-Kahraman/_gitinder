export interface Repo {
  id: number;
  name: string;
  full_name: string;
  owner: {
    login: string;
    avatar_url: string;
  };
  description: string | null;
  stargazers_count: number;
  forks_count: number;
  open_issues_count: number;
  language: string | null;
  topics: string[];
  html_url: string;
  pushed_at: string;
}

export interface User {
  login: string;
  avatar_url: string;
  name: string | null;
  public_repos: number;
  followers: number;
}

export type LanguageMap = Record<string, number>;

export const LANGUAGE_COLORS: Record<string, string> = {
  TypeScript: '#3178c6',
  JavaScript: '#f1e05a',
  Python: '#3572A5',
  Rust: '#dea584',
  Go: '#00ADD8',
  Java: '#b07219',
  'C++': '#f34b7d',
  C: '#555555',
  Ruby: '#701516',
  Swift: '#F05138',
  Kotlin: '#A97BFF',
  PHP: '#4F5D95',
  'C#': '#178600',
  Shell: '#89e051',
  Dart: '#00B4AB',
  Scala: '#c22d40',
  Haskell: '#5e5086',
  Elixir: '#6e4a7e',
  Vue: '#41b883',
  HTML: '#e34c26',
};

import { useState, useEffect } from 'react';
import { Star, GitFork, AlertCircle, ExternalLink } from 'lucide-react';
import { getRepoLanguages } from '../api/github';
import { LANGUAGE_COLORS } from '../types/github';
import type { Repo, LanguageMap } from '../types/github';
import LanguageBar from './LanguageBar';

interface Props {
  repo: Repo;
  style?: React.CSSProperties;
  className?: string;
  overlay?: 'left' | 'right' | null;
}

function formatCount(n: number): string {
  if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
  return String(n);
}

export default function RepoCard({ repo, style, className = '', overlay }: Props) {
  const [languages, setLanguages] = useState<LanguageMap>({});

  useEffect(() => {
    let cancelled = false;
    getRepoLanguages(repo.owner.login, repo.name).then((data) => {
      if (!cancelled) setLanguages(data);
    });
    return () => { cancelled = true; };
  }, [repo.owner.login, repo.name]);

  return (
    <div
      className={`absolute w-full max-w-sm bg-card border border-border rounded-2xl p-5 select-none ${className}`}
      style={style}
    >
      {overlay === 'right' && (
        <div className="absolute inset-0 rounded-2xl flex items-center justify-center pointer-events-none z-10">
          <div className="absolute inset-0 rounded-2xl bg-accent-green/10" />
          <span className="text-accent-green text-4xl font-mono font-bold border-4 border-accent-green rounded-xl px-6 py-2 -rotate-[20deg]">
            STAR ★
          </span>
        </div>
      )}
      {overlay === 'left' && (
        <div className="absolute inset-0 rounded-2xl flex items-center justify-center pointer-events-none z-10">
          <div className="absolute inset-0 rounded-2xl bg-accent-red/10" />
          <span className="text-accent-red text-4xl font-mono font-bold border-4 border-accent-red rounded-xl px-6 py-2 rotate-[20deg]">
            SKIP ✕
          </span>
        </div>
      )}

      <div className="flex items-start justify-between mb-3">
        <div className="flex-1 min-w-0">
          <a
            href={repo.html_url}
            target="_blank"
            rel="noopener noreferrer"
            className="text-accent-green font-mono font-bold text-lg hover:underline inline-flex items-center gap-1"
            onClick={(e) => e.stopPropagation()}
          >
            {repo.name}
            <ExternalLink size={14} className="opacity-50" />
          </a>
          <p className="text-secondary text-xs font-mono mt-0.5">{repo.owner.login}</p>
        </div>
        <img
          src={repo.owner.avatar_url}
          alt={repo.owner.login}
          className="w-10 h-10 rounded-full border border-border ml-3 flex-shrink-0"
        />
      </div>

      {repo.description && (
        <p className="text-primary/80 text-sm font-body leading-relaxed mb-3 line-clamp-3">
          {repo.description}
        </p>
      )}

      {repo.topics.length > 0 && (
        <div className="flex flex-wrap gap-1.5 mb-3">
          {repo.topics.slice(0, 6).map((topic) => (
            <span
              key={topic}
              className="text-xs font-mono px-2 py-0.5 rounded-full bg-border text-secondary"
            >
              {topic}
            </span>
          ))}
        </div>
      )}

      <div className="flex items-center gap-4 text-xs font-mono text-secondary mb-3">
        <span className="flex items-center gap-1">
          <Star size={13} /> {formatCount(repo.stargazers_count)}
        </span>
        <span className="flex items-center gap-1">
          <GitFork size={13} /> {formatCount(repo.forks_count)}
        </span>
        <span className="flex items-center gap-1">
          <AlertCircle size={13} /> {formatCount(repo.open_issues_count)}
        </span>
        {repo.language && (
          <span className="flex items-center gap-1">
            <span
              className="w-2.5 h-2.5 rounded-full inline-block"
              style={{ backgroundColor: LANGUAGE_COLORS[repo.language] || '#6b6b80' }}
            />
            {repo.language}
          </span>
        )}
      </div>

      <LanguageBar languages={languages} />

      <a
        href={repo.html_url}
        target="_blank"
        rel="noopener noreferrer"
        className="mt-3 flex items-center justify-center gap-2 w-full py-2 rounded-lg border border-border text-secondary text-xs font-mono hover:text-accent-green hover:border-accent-green/50 transition-colors"
        onClick={(e) => e.stopPropagation()}
        onPointerDown={(e) => e.stopPropagation()}
        onTouchStart={(e) => e.stopPropagation()}
      >
        <ExternalLink size={13} />
        Open on GitHub
      </a>
    </div>
  );
}

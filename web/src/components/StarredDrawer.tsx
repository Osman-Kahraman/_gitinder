import { X, ExternalLink, Star, Trash2 } from 'lucide-react';
import { LANGUAGE_COLORS } from '../types/github';
import type { StarredEntry } from '../hooks/useStarredHistory';

interface Props {
  open: boolean;
  history: StarredEntry[];
  onClose: () => void;
  onClear: () => void;
}

function timeAgo(ts: number): string {
  const diff = Date.now() - ts;
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  return `${days}d ago`;
}

export default function StarredDrawer({ open, history, onClose, onClear }: Props) {
  return (
    <>
      {open && (
        <div className="fixed inset-0 bg-black/60 z-40" onClick={onClose} />
      )}

      <div
        className={`fixed top-0 right-0 h-full w-full max-w-sm bg-bg border-l border-border z-50 transform transition-transform duration-300 ease-out ${
          open ? 'translate-x-0' : 'translate-x-full'
        }`}
      >
        <div className="flex items-center justify-between px-4 py-3 border-b border-border">
          <h2 className="text-primary font-mono font-bold text-sm flex items-center gap-2">
            <Star size={16} className="text-accent-green" />
            Starred History
          </h2>
          <button
            onClick={onClose}
            className="text-secondary hover:text-primary transition-colors p-1 cursor-pointer"
          >
            <X size={20} />
          </button>
        </div>

        <div className="overflow-y-auto h-[calc(100%-108px)]">
          {history.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-secondary font-mono text-sm gap-2">
              <Star size={32} className="opacity-30" />
              <p>No starred repos yet</p>
              <p className="text-xs">Swipe right to star repos</p>
            </div>
          ) : (
            <div className="divide-y divide-border">
              {history.map((entry) => (
                <a
                  key={entry.id}
                  href={entry.html_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-start gap-3 px-4 py-3 hover:bg-card transition-colors group"
                >
                  <img
                    src={entry.owner_avatar}
                    alt={entry.owner_login}
                    className="w-8 h-8 rounded-full border border-border flex-shrink-0 mt-0.5"
                  />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5">
                      <span className="text-accent-green font-mono font-bold text-sm truncate">
                        {entry.name}
                      </span>
                      <ExternalLink size={11} className="text-secondary opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0" />
                    </div>
                    <p className="text-secondary text-xs font-mono">{entry.owner_login}</p>
                    {entry.description && (
                      <p className="text-primary/60 text-xs font-body mt-1 line-clamp-2">
                        {entry.description}
                      </p>
                    )}
                    <div className="flex items-center gap-3 mt-1.5 text-xs font-mono text-secondary">
                      <span className="flex items-center gap-1">
                        <Star size={10} /> {entry.stargazers_count.toLocaleString()}
                      </span>
                      {entry.language && (
                        <span className="flex items-center gap-1">
                          <span
                            className="w-2 h-2 rounded-full inline-block"
                            style={{ backgroundColor: LANGUAGE_COLORS[entry.language] || '#6b6b80' }}
                          />
                          {entry.language}
                        </span>
                      )}
                      <span className="ml-auto opacity-60">{timeAgo(entry.starred_at)}</span>
                    </div>
                  </div>
                </a>
              ))}
            </div>
          )}
        </div>

        {history.length > 0 && (
          <div className="absolute bottom-0 left-0 right-0 px-4 py-3 border-t border-border bg-bg">
            <button
              onClick={onClear}
              className="flex items-center justify-center gap-2 w-full py-2 rounded-lg border border-border text-secondary text-xs font-mono hover:text-accent-red hover:border-accent-red/50 transition-colors cursor-pointer"
            >
              <Trash2 size={13} />
              Clear history ({history.length})
            </button>
          </div>
        )}
      </div>
    </>
  );
}

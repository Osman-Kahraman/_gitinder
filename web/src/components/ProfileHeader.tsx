import { LogOut, Star } from 'lucide-react';
import type { User } from '../types/github';

interface Props {
  user: User;
  starredCount: number;
  onLogout: () => void;
  onOpenHistory: () => void;
}

export default function ProfileHeader({ user, starredCount, onLogout, onOpenHistory }: Props) {
  return (
    <div className="flex items-center justify-between w-full max-w-md mx-auto px-4 py-3">
      <div className="flex items-center gap-3">
        <img
          src={user.avatar_url}
          alt={user.login}
          className="w-9 h-9 rounded-full border border-border"
        />
        <div>
          <p className="text-primary text-sm font-body font-medium">{user.name || user.login}</p>
          <p className="text-secondary text-xs font-mono">@{user.login}</p>
        </div>
      </div>
      <div className="flex items-center gap-1">
        <button
          onClick={onOpenHistory}
          className="relative text-secondary hover:text-accent-green transition-colors p-2 cursor-pointer"
          title="Starred history"
        >
          <Star size={18} />
          {starredCount > 0 && (
            <span className="absolute -top-0.5 -right-0.5 bg-accent-green text-bg text-[10px] font-mono font-bold w-4 h-4 rounded-full flex items-center justify-center">
              {starredCount > 99 ? '99' : starredCount}
            </span>
          )}
        </button>
        <button
          onClick={onLogout}
          className="text-secondary hover:text-accent-red transition-colors p-2 cursor-pointer"
          title="Logout"
        >
          <LogOut size={18} />
        </button>
      </div>
    </div>
  );
}

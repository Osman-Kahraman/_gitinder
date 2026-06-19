import { X, Star } from 'lucide-react';

interface Props {
  onSkip: () => void;
  onStar: () => void;
}

export default function ActionBar({ onSkip, onStar }: Props) {
  return (
    <div className="flex items-center justify-center gap-8 py-6">
      <button
        onClick={onSkip}
        className="w-16 h-16 rounded-full border-2 border-accent-red flex items-center justify-center text-accent-red hover:bg-accent-red/10 hover:shadow-[0_0_20px_rgba(255,68,88,0.3)] active:scale-95 transition-all duration-200 cursor-pointer"
        title="Skip (← arrow)"
      >
        <X size={28} strokeWidth={3} />
      </button>
      <button
        onClick={onStar}
        className="w-16 h-16 rounded-full border-2 border-accent-green flex items-center justify-center text-accent-green hover:bg-accent-green/10 hover:shadow-[0_0_20px_rgba(0,255,136,0.3)] active:scale-95 transition-all duration-200 cursor-pointer"
        title="Star (→ arrow)"
      >
        <Star size={28} strokeWidth={3} />
      </button>
    </div>
  );
}

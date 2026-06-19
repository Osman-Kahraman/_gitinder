import { LANGUAGE_COLORS } from '../types/github';
import type { LanguageMap } from '../types/github';

interface Props {
  languages: LanguageMap;
}

export default function LanguageBar({ languages }: Props) {
  const entries = Object.entries(languages).sort((a, b) => b[1] - a[1]);
  const total = entries.reduce((sum, [, bytes]) => sum + bytes, 0);

  if (total === 0) return null;

  const top5 = entries.slice(0, 5);
  const otherBytes = entries.slice(5).reduce((sum, [, bytes]) => sum + bytes, 0);
  if (otherBytes > 0) top5.push(['Other', otherBytes]);

  return (
    <div className="w-full">
      <div className="flex h-1.5 rounded-full overflow-hidden bg-border">
        {top5.map(([lang, bytes]) => {
          const pct = (bytes / total) * 100;
          const color = LANGUAGE_COLORS[lang] || '#6b6b80';
          return (
            <div
              key={lang}
              className="h-full transition-all duration-300"
              style={{ width: `${pct}%`, backgroundColor: color }}
              title={`${lang}: ${pct.toFixed(1)}%`}
            />
          );
        })}
      </div>
      <div className="flex flex-wrap gap-x-3 gap-y-1 mt-2">
        {top5.map(([lang, bytes]) => {
          const pct = ((bytes / total) * 100).toFixed(1);
          const color = LANGUAGE_COLORS[lang] || '#6b6b80';
          return (
            <span key={lang} className="flex items-center gap-1 text-xs text-secondary font-mono">
              <span className="w-2 h-2 rounded-full inline-block" style={{ backgroundColor: color }} />
              {lang} {pct}%
            </span>
          );
        })}
      </div>
    </div>
  );
}

import { Github } from 'lucide-react';

interface Props {
  onLogin: () => void;
}

const ASCII_LOGO = `
 _ _   _           _           
| | |_(_)_ __   __| | ___ _ __ 
| | __| | '_ \\ / _\` |/ _ \\ '__|
| | |_| | | | | (_| |  __/ |   
|_|\\__|_|_| |_|\\__,_|\\___|_|   
`;

export default function LoginScreen({ onLogin }: Props) {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-bg px-6">
      <pre className="text-accent-green font-mono text-xs sm:text-sm leading-tight mb-8 select-none">
        {ASCII_LOGO}
      </pre>

      <button
        onClick={onLogin}
        className="flex items-center gap-3 bg-card border border-border rounded-xl px-8 py-4 text-primary font-body text-lg hover:border-accent-green hover:shadow-[0_0_20px_rgba(0,255,136,0.15)] transition-all duration-300 cursor-pointer"
      >
        <Github size={24} />
        Login with GitHub
      </button>

      <p className="mt-6 text-secondary font-mono text-sm tracking-wide">
        swipe repos. star what matters.
      </p>
    </div>
  );
}

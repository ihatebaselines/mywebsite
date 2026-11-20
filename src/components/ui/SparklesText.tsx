'use client';

import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';

interface Sparkle {
  id: string;
  x: string;
  y: string;
  color: string;
  delay: number;
  scale: number;
}

export interface SparklesTextProps {
  children: React.ReactNode;
  sparklesCount?: number;
  colors?: { first: string; second: string };
  className?: string;
}

export const SparklesText: React.FC<SparklesTextProps> = ({
  children,
  sparklesCount = 8,
  colors = { first: '#38bdf8', second: '#e0f7fa' },
  className = '',
}) => {
  const [sparkles, setSparkles] = useState<Sparkle[]>([]);

  useEffect(() => {
    const generate = (): Sparkle[] =>
      Array.from({ length: sparklesCount }, (_, i) => ({
        id: `sp-${i}-${Math.random().toString(36).slice(2, 6)}`,
        x: `${Math.random() * 100}%`,
        y: `${Math.random() * 100}%`,
        color: i % 2 === 0 ? colors.first : colors.second,
        delay: Math.random() * 2,
        scale: 0.5 + Math.random() * 0.7,
      }));

    setSparkles(generate());
    const timer = setInterval(() => setSparkles(generate()), 3200);
    return () => clearInterval(timer);
  }, [sparklesCount, colors.first, colors.second]);

  return (
    <span className={`sparkles-text-wrap ${className}`} style={{ position: 'relative', display: 'inline-block' }}>
      <span style={{ position: 'relative', zIndex: 2 }}>{children}</span>
      {sparkles.map((sp) => (
        <motion.svg
          key={sp.id}
          viewBox="0 0 24 24"
          width="14"
          height="14"
          aria-hidden="true"
          initial={{ opacity: 0, scale: 0, rotate: 0 }}
          animate={{ opacity: [0, 1, 0], scale: [0, sp.scale, 0], rotate: [0, 90, 180] }}
          transition={{ duration: 1.6, delay: sp.delay, ease: 'easeInOut' }}
          style={{
            position: 'absolute',
            left: sp.x,
            top: sp.y,
            pointerEvents: 'none',
            zIndex: 3,
          }}
        >
          <path
            d="M12 0L14.5 9.5L24 12L14.5 14.5L12 24L9.5 14.5L0 12L9.5 9.5L12 0Z"
            fill={sp.color}
          />
        </motion.svg>
      ))}
    </span>
  );
};

export default SparklesText;

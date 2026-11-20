'use client';

import React, { useEffect, useState } from 'react';

export type TypeWritterProps = {
  text: string;
  charDelay?: number;
  startDelay?: number;
  loop?: boolean;
  pauseMs?: number;
  showCursor?: boolean;
  className?: string;
  onComplete?: () => void;
};

export const TypeWritter: React.FC<TypeWritterProps> = ({
  text,
  charDelay = 55,
  startDelay = 200,
  loop = false,
  pauseMs = 2400,
  showCursor = true,
  className = '',
  onComplete,
}) => {
  const [displayed, setDisplayed] = useState('');
  const [cycle, setCycle] = useState(0);

  useEffect(() => {
    let idx = 0;
    let intervalId: ReturnType<typeof setInterval> | null = null;
    let loopTimeoutId: ReturnType<typeof setTimeout> | null = null;

    setDisplayed('');

    const startTimeoutId = setTimeout(() => {
      intervalId = setInterval(() => {
        idx += 1;
        setDisplayed(text.slice(0, idx));

        if (idx >= text.length) {
          if (intervalId) clearInterval(intervalId);
          onComplete?.();
          if (loop) {
            loopTimeoutId = setTimeout(() => {
              setCycle((c) => c + 1);
            }, pauseMs);
          }
        }
      }, charDelay);
    }, startDelay);

    return () => {
      clearTimeout(startTimeoutId);
      if (intervalId) clearInterval(intervalId);
      if (loopTimeoutId) clearTimeout(loopTimeoutId);
    };
  }, [text, charDelay, startDelay, loop, pauseMs, cycle, onComplete]);

  return (
    <span className={`typewritter-wrap ${className}`}>
      <span>{displayed}</span>
      {showCursor ? (
        <span className="typewritter-cursor" aria-hidden="true">
          _
        </span>
      ) : null}
    </span>
  );
};

export default TypeWritter;

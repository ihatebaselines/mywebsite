'use client';

import React, { useEffect, useState, useRef, useMemo } from 'react';

export type ActiveDivsMap = Record<number, Set<number>>;

export type BlocksProps = {
  blockSize?: number;
  activeDivsClass?: string;
  divClass?: string;
  className?: string;
  activeDivs?: ActiveDivsMap;
  containerRef?: React.RefObject<HTMLElement | null>;
  interactive?: boolean;
};

export const Blocks: React.FC<BlocksProps> = ({
  blockSize = 48,
  activeDivsClass = 'block-cell-active',
  divClass = 'block-cell',
  className = '',
  activeDivs = {},
  containerRef,
  interactive = true,
}) => {
  const localRef = useRef<HTMLDivElement>(null);
  const targetRef = containerRef || localRef;

  const [dimensions, setDimensions] = useState({ cols: 16, rows: 10 });
  const [hoveredCell, setHoveredCell] = useState<{ row: number; col: number } | null>(null);

  useEffect(() => {
    const updateSize = () => {
      const el = targetRef.current;
      if (!el) return;
      const width = el.offsetWidth || window.innerWidth;
      const height = el.offsetHeight || 500;
      const cols = Math.ceil(width / blockSize) + 1;
      const rows = Math.ceil(height / blockSize) + 1;
      setDimensions({ cols, rows });
    };

    updateSize();
    window.addEventListener('resize', updateSize);
    return () => window.removeEventListener('resize', updateSize);
  }, [blockSize, targetRef]);

  // Track pointer movements on container element directly
  useEffect(() => {
    const el = targetRef.current;
    if (!interactive || !el) return;

    const handlePointerMove = (e: MouseEvent) => {
      const rect = el.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const col = Math.floor(x / blockSize);
      const row = Math.floor(y / blockSize);
      setHoveredCell({ row, col });
    };

    const handlePointerLeave = () => {
      setHoveredCell(null);
    };

    el.addEventListener('mousemove', handlePointerMove);
    el.addEventListener('mouseleave', handlePointerLeave);

    return () => {
      el.removeEventListener('mousemove', handlePointerMove);
      el.removeEventListener('mouseleave', handlePointerLeave);
    };
  }, [interactive, targetRef, blockSize]);

  const defaultActiveDivs = useMemo<ActiveDivsMap>(() => ({
    0: new Set([2, 5, 8, 12]),
    1: new Set([0, 7, 14]),
    2: new Set([3, 6, 10]),
    3: new Set([1, 8, 15]),
    4: new Set([4, 9]),
    5: new Set([2, 7, 11]),
    6: new Set([0, 5, 13]),
    7: new Set([3, 8]),
    8: new Set([1, 6, 12]),
  }), []);

  const effectiveActive = Object.keys(activeDivs).length > 0 ? activeDivs : defaultActiveDivs;

  return (
    <div
      ref={localRef}
      className={`blocks-grid-container ${className}`}
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${dimensions.cols}, ${blockSize}px)`,
        gridTemplateRows: `repeat(${dimensions.rows}, ${blockSize}px)`,
      }}
      aria-hidden="true"
    >
      {Array.from({ length: dimensions.rows }).map((_, r) => (
        <React.Fragment key={`row-${r}`}>
          {Array.from({ length: dimensions.cols }).map((_, c) => {
            const isPresetActive = effectiveActive[r]?.has(c);
            const isHovered = hoveredCell && Math.abs(hoveredCell.row - r) <= 1 && Math.abs(hoveredCell.col - c) <= 1;
            const isExact = hoveredCell?.row === r && hoveredCell?.col === c;

            const activeClass = (isPresetActive || isHovered) ? activeDivsClass : '';
            const exactClass = isExact ? 'block-cell-exact' : '';

            return (
              <div
                key={`cell-${r}-${c}`}
                className={`${divClass} ${activeClass} ${exactClass}`}
              />
            );
          })}
        </React.Fragment>
      ))}
    </div>
  );
};

export default Blocks;

'use client';

import React, { useRef } from 'react';
import Blocks from './Blocks';

export type BlocksBackgroundProps = {
  className?: string;
  children?: React.ReactNode;
  height?: string;
};

export const BlocksBackground: React.FC<BlocksBackgroundProps> = ({
  className = '',
  children,
  height = '100%',
}) => {
  const containerRef = useRef<HTMLDivElement>(null);

  return (
    <div
      ref={containerRef}
      className={`blocks-bg-wrapper ${className}`}
      style={{ minHeight: height }}
    >
      <div className="blocks-bg-layer" aria-hidden="true">
        <Blocks containerRef={containerRef} blockSize={44} />
      </div>

      {/* Top & Bottom Ambient Fade Masks */}
      <div className="blocks-gradient-mask" aria-hidden="true" />

      {/* Content */}
      {children ? <div className="blocks-bg-content">{children}</div> : null}
    </div>
  );
};

export default BlocksBackground;

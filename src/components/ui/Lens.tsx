'use client';

import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';

export interface LensProps {
  children: React.ReactNode;
  zoomFactor?: number;
  lensSize?: number;
  isStatic?: boolean;
  ariaLabel?: string;
}

export const Lens: React.FC<LensProps> = ({
  children,
  zoomFactor = 1.75,
  lensSize = 130,
  isStatic = false,
  ariaLabel = 'Zoom Area',
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isHovering, setIsHovering] = useState(false);
  const [mousePos, setMousePos] = useState({ x: 100, y: 100 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = containerRef.current?.getBoundingClientRect();
    if (!rect) return;
    setMousePos({
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    });
  };

  return (
    <div
      ref={containerRef}
      className="lens-container"
      aria-label={ariaLabel}
      onMouseEnter={() => setIsHovering(true)}
      onMouseLeave={() => setIsHovering(false)}
      onMouseMove={handleMouseMove}
      style={{ position: 'relative', overflow: 'hidden', width: '100%', height: '100%' }}
    >
      {children}

      <AnimatePresence>
        {(isHovering || isStatic) && (
          <motion.div
            initial={{ opacity: 0, scale: 0.6 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.6 }}
            transition={{ duration: 0.16, ease: 'easeOut' }}
            style={{
              position: 'absolute',
              inset: 0,
              pointerEvents: 'none',
              zIndex: 10,
              maskImage: `radial-gradient(circle ${lensSize / 2}px at ${mousePos.x}px ${mousePos.y}px, black 100%, transparent 100%)`,
              WebkitMaskImage: `radial-gradient(circle ${lensSize / 2}px at ${mousePos.x}px ${mousePos.y}px, black 100%, transparent 100%)`,
              transformOrigin: `${mousePos.x}px ${mousePos.y}px`,
              transform: `scale(${zoomFactor})`,
            }}
          >
            {children}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default Lens;

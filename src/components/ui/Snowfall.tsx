'use client';

import React, { useEffect, useRef } from 'react';

export default function Snowfall() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReduced) return;

    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId = 0;
    let width = (canvas.width = window.innerWidth);
    let height = (canvas.height = window.innerHeight);
    let docHeight = Math.max(document.documentElement.scrollHeight, height);

    const handleResize = () => {
      if (!canvas) return;
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
      docHeight = Math.max(document.documentElement.scrollHeight, height);
    };

    window.addEventListener('resize', handleResize);

    // Flakes live in document-space coordinates (0 .. docHeight)
    // Start them near the top / initial viewport so they flow down the page like water
    const count = Math.min(90, Math.floor((width * docHeight) / 35000));
    const flakes = Array.from({ length: count }, () => ({
      x: Math.random() * width,
      y: Math.random() * Math.min(docHeight, height * 1.3),
      size: Math.random() > 0.65 ? 3 : 2,
      speedY: 0.45 + Math.random() * 0.75,
      speedX: (Math.random() - 0.5) * 0.25,
      alpha: 0.2 + Math.random() * 0.35,
    }));

    const render = () => {
      ctx.clearRect(0, 0, width, height);
      const scrollY = window.scrollY;
      docHeight = Math.max(document.documentElement.scrollHeight, height);

      for (const f of flakes) {
        f.y += f.speedY;
        f.x += f.speedX;

        if (f.y > docHeight) {
          f.y = -4;
          f.x = Math.random() * width;
        }
        if (f.x > width) f.x = 0;
        if (f.x < 0) f.x = width;

        // Convert document Y to screen Y: if you scroll past them, they stay above!
        const screenY = f.y - scrollY;
        if (screenY >= -4 && screenY <= height + 4) {
          ctx.fillStyle = `rgba(224, 247, 250, ${f.alpha})`;
          ctx.fillRect(Math.round(f.x), Math.round(screenY), f.size, f.size);
        }
      }
      animId = requestAnimationFrame(render);
    };

    animId = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      style={{
        position: 'fixed',
        inset: 0,
        width: '100vw',
        height: '100vh',
        pointerEvents: 'none',
        zIndex: 50,
      }}
    />
  );
}

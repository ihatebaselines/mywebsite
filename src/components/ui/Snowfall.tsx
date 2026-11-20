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

    const count = Math.min(75, Math.floor((width * docHeight) / 40000));
    const flakes = Array.from({ length: count }, () => ({
      x: Math.random() * width,
      y: Math.random() * docHeight,
      variant: Math.random() > 0.45 ? 1 : 0, // 1 = 5x5 pixel snowflake, 0 = 3x3 pixel plus
      speedY: 0.45 + Math.random() * 0.75,
      speedX: (Math.random() - 0.5) * 0.25,
      alpha: 0.22 + Math.random() * 0.35,
    }));

    const drawPixelFlake = (x: number, y: number, variant: number, alpha: number) => {
      ctx.fillStyle = `rgba(224, 247, 250, ${alpha})`;
      const px = Math.round(x);
      const py = Math.round(y);
      const u = 1.5; // crisp pixel unit

      if (variant === 0) {
        // 3x3 pixel plus (+)
        ctx.fillRect(px, py - u, u, u * 3);
        ctx.fillRect(px - u, py, u * 3, u);
      } else {
        // 5x5 pixel crystalline snowflake (*)
        ctx.fillRect(px, py - u * 2, u, u * 5); // vertical bar
        ctx.fillRect(px - u * 2, py, u * 5, u); // horizontal bar
        // diagonal tips
        ctx.fillRect(px - u, py - u, u, u);
        ctx.fillRect(px + u, py - u, u, u);
        ctx.fillRect(px - u, py + u, u, u);
        ctx.fillRect(px + u, py + u, u, u);
      }
    };

    const render = () => {
      ctx.clearRect(0, 0, width, height);
      const scrollY = window.scrollY;
      docHeight = Math.max(document.documentElement.scrollHeight, height);

      for (const f of flakes) {
        f.y += f.speedY;
        f.x += f.speedX;

        if (f.y > docHeight) {
          f.y = -6;
          f.x = Math.random() * width;
        }
        if (f.x > width) f.x = 0;
        if (f.x < 0) f.x = width;

        const screenY = f.y - scrollY;
        if (screenY >= -8 && screenY <= height + 8) {
          drawPixelFlake(f.x, screenY, f.variant, f.alpha);
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

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
    let lastScrollY = window.scrollY;
    let scrollVelocity = 0;

    const handleResize = () => {
      if (!canvas) return;
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
    };

    const handleScroll = () => {
      const currentY = window.scrollY;
      const delta = currentY - lastScrollY;
      lastScrollY = currentY;
      // Add scroll inertia so particles react physically as you scroll
      scrollVelocity += delta * 0.45;
    };

    window.addEventListener('resize', handleResize);
    window.addEventListener('scroll', handleScroll, { passive: true });

    const count = Math.min(56, Math.floor((width * height) / 28000));
    const flakes = Array.from({ length: count }, () => {
      const depth = 0.4 + Math.random() * 1.1;
      return {
        x: Math.random() * width,
        y: Math.random() * height,
        size: depth > 1.1 ? 3 : 2,
        depth,
        speedY: (0.3 + Math.random() * 0.55) * depth,
        speedX: (Math.random() - 0.5) * 0.25,
        alpha: 0.16 + depth * 0.22,
      };
    });

    const render = () => {
      ctx.clearRect(0, 0, width, height);

      // Smoothly decay scroll velocity each frame
      scrollVelocity *= 0.88;

      for (const f of flakes) {
        // Particles move downward naturally + react to scroll velocity by depth
        f.y += f.speedY + scrollVelocity * f.depth * 0.35;
        f.x += f.speedX;

        // Wrap around viewport vertically & horizontally
        if (f.y > height + 4) {
          f.y = -4;
          f.x = Math.random() * width;
        } else if (f.y < -4) {
          f.y = height + 4;
          f.x = Math.random() * width;
        }
        if (f.x > width) f.x = 0;
        if (f.x < 0) f.x = width;

        ctx.fillStyle = `rgba(224, 247, 250, ${Math.min(0.65, f.alpha)})`;
        ctx.fillRect(Math.round(f.x), Math.round(f.y), f.size, f.size);
      }
      animId = requestAnimationFrame(render);
    };

    animId = requestAnimationFrame(render);

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('resize', handleResize);
      window.removeEventListener('scroll', handleScroll);
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

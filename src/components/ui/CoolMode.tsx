'use client';

import React, { useEffect, useRef } from 'react';

export interface CoolModeOptions {
  particle?: string;
  size?: number;
  particleCount?: number;
  speedHorz?: number;
  speedUp?: number;
}

interface CoolModeProps {
  children: React.ReactNode;
  options?: CoolModeOptions;
}

export const CoolMode: React.FC<CoolModeProps> = ({ children, options = {} }) => {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const {
      particle,
      size = 22,
      particleCount = 14,
      speedHorz = 5,
      speedUp = 10,
    } = options;

    const colors = ['#38bdf8', '#67e8f9', '#e0f7fa', '#818cf8', '#ffffff'];

    const handleClick = (e: MouseEvent) => {
      const container = document.createElement('div');
      container.style.cssText =
        'position:fixed;inset:0;pointer-events:none;z-index:9999;overflow:hidden;';
      document.body.appendChild(container);

      const particles: Array<{
        node: HTMLElement;
        x: number;
        y: number;
        vx: number;
        vy: number;
        rot: number;
        vRot: number;
        life: number;
      }> = [];

      for (let i = 0; i < particleCount; i++) {
        const node = document.createElement('div');
        node.style.position = 'absolute';
        node.style.left = '0px';
        node.style.top = '0px';
        node.style.willChange = 'transform, opacity';

        if (particle) {
          const img = document.createElement('img');
          img.src = particle;
          img.style.width = `${size}px`;
          img.style.height = `${size}px`;
          img.style.borderRadius = '4px';
          img.style.objectFit = 'cover';
          node.appendChild(img);
        } else {
          node.textContent = i % 2 === 0 ? '❄' : '✦';
          node.style.fontSize = `${size * 0.8}px`;
          node.style.color = colors[i % colors.length];
        }

        container.appendChild(node);
        particles.push({
          node,
          x: e.clientX - size / 2,
          y: e.clientY - size / 2,
          vx: (Math.random() - 0.5) * 2 * speedHorz,
          vy: -(Math.random() * speedUp + 3),
          rot: Math.random() * 360,
          vRot: (Math.random() - 0.5) * 14,
          life: 1,
        });
      }

      let animId = 0;
      const tick = () => {
        let alive = false;
        for (const p of particles) {
          if (p.life <= 0) continue;
          alive = true;
          p.vy += 0.45; // gravity
          p.x += p.vx;
          p.y += p.vy;
          p.rot += p.vRot;
          p.life -= 0.018;

          p.node.style.transform = `translate3d(${p.x}px, ${p.y}px, 0) rotate(${p.rot}deg)`;
          p.node.style.opacity = `${Math.max(0, p.life)}`;
        }
        if (alive) {
          animId = requestAnimationFrame(tick);
        } else {
          cancelAnimationFrame(animId);
          container.remove();
        }
      };
      animId = requestAnimationFrame(tick);
    };

    el.addEventListener('click', handleClick);
    return () => el.removeEventListener('click', handleClick);
  }, [options]);

  return (
    <div ref={ref} style={{ display: 'inline-block' }}>
      {children}
    </div>
  );
};

export default CoolMode;

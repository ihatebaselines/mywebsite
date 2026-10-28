"use client";

import { useEffect, useRef } from "react";

export default function DnaBackground() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const W = 16;
    const A = 6;
    const PERIOD = 31;
    const SHIFT = 3;
    const CX = W / 2;

    const offscreen = document.createElement("canvas");
    const offCtx = offscreen.getContext("2d");
    if (!offCtx) return;

    function inStrand(x: number, y: number, phase: number, sign: number) {
      const s = sign * A * Math.sin((2 * Math.PI * y) / PERIOD + phase);
      const d = x + 0.5 - CX;
      return (d > 0 && d <= s) || (d < 0 && d >= s);
    }

    let animId: number;
    let lastRenderedPhase = -999999;
    let lastW = 0;
    let lastH = 0;

    const render = () => {
      const scrollY = window.scrollY;

      // Faza este 100% legată direct de window.scrollY!
      // Dacă scrollY nu se schimbă (utilizatorul NU dă scroll), phase este o constantă fixă, deci ADN-ul este 100% înghețat/static.
      // Când scrollY se mișcă (cu Lenis), faza se schimbă lin. Când Lenis se oprește, faza se oprește complet.
      const phase = (scrollY / PERIOD) * (2 * Math.PI) * 0.45;

      const winW = window.innerWidth;
      const winH = window.innerHeight;

      if (canvas.width !== winW || canvas.height !== winH) {
        canvas.width = winW;
        canvas.height = winH;
      }

      const pixelScale = 3;
      const H = Math.ceil(winH / pixelScale);

      if (offscreen.width !== W || offscreen.height !== H) {
        offscreen.width = W;
        offscreen.height = H;
        lastW = W;
        lastH = H;
        lastRenderedPhase = -999999; // forțează re-desenarea la resize
      }

      // DOAR dacă poziția de scroll s-a schimbat față de ultimul cadru randat
      if (Math.abs(phase - lastRenderedPhase) > 0.0001) {
        lastRenderedPhase = phase;

        const img = offCtx.createImageData(W, H);
        const px = img.data;

        for (let y = 0; y < H; y++) {
          for (let x = 0; x < W; x++) {
            const r = inStrand(x, y, phase, +1) ? 0 : 255;
            const g = inStrand(x, y + SHIFT, phase, -1) ? 0 : 255;
            const b = inStrand(x, y - SHIFT, phase, -1) ? 0 : 255;

            const i = (y * W + x) * 4;
            px[i] = r;
            px[i + 1] = g;
            px[i + 2] = b;

            if (r === 255 && g === 255 && b === 255) {
              px[i + 3] = 0;
            } else {
              px[i + 3] = 255;
            }
          }
        }

        offCtx.putImageData(img, 0, 0);

        ctx.clearRect(0, 0, winW, winH);
        ctx.imageSmoothingEnabled = false;

        const strandDisplayWidth = W * pixelScale; // ~48px
        // Desenează de la top: 0 până la bottom: winH pe toată înălțimea ecranului
        ctx.drawImage(offscreen, 0, 0, strandDisplayWidth, winH);
      }

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animId);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        width: "100vw",
        height: "100vh",
        pointerEvents: "none",
        zIndex: -1,
        imageRendering: "pixelated",
      }}
      aria-hidden="true"
    />
  );
}

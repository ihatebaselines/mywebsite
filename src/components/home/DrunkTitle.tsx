"use client";

import { useEffect, useRef, useState } from "react";
import { useHeroGlitch } from "./heroState";

export default function DrunkTitle() {
  const isGlitch = useHeroGlitch();
  const [mounted, setMounted] = useState(false);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!isGlitch) return;
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    // Grid sizes: low-res grid for pixelation (single unified line)
    const W = 360;
    const H = 80;

    const offscreen = document.createElement("canvas");
    offscreen.width = W;
    offscreen.height = H;
    const offCtx = offscreen.getContext("2d", { willReadFrequently: true });
    if (!offCtx) return;

    let R = new Uint8Array(W * H);
    let G = new Uint8Array(W * H);
    let B = new Uint8Array(W * H);

    const rollX = (src: Uint8Array, shift: number) => {
      const out = new Uint8Array(W * H);
      const s = ((shift % W) + W) % W;
      for (let y = 0; y < H; y++) {
        const row = y * W;
        for (let x = 0; x < W; x++) {
          const srcX = (x - s + W) % W;
          out[row + x] = src[row + srcX];
        }
      }
      return out;
    };

    const rollY = (src: Uint8Array, shift: number) => {
      const out = new Uint8Array(W * H);
      const s = ((shift % H) + H) % H;
      for (let y = 0; y < H; y++) {
        const srcY = ((y - s) % H + H) % H;
        const targetRow = y * W;
        const sourceRow = srcY * W;
        for (let x = 0; x < W; x++) {
          out[targetRow + x] = src[sourceRow + x];
        }
      }
      return out;
    };

    const reflect = (val: number, max: number) => {
      let v = val;
      while (v < 0 || v >= max) {
        if (v < 0) v = -v - 1;
        if (v >= max) v = 2 * max - v - 1;
      }
      return v;
    };

    let targetScroll = window.scrollY;
    let currentScroll = window.scrollY;

    const handleScroll = () => {
      targetScroll = window.scrollY;
    };
    window.addEventListener("scroll", handleScroll, { passive: true });

    let animId: number;
    let prevPhase = -1;

    const render = () => {
      currentScroll += (targetScroll - currentScroll) * 0.085;
      const scrollPhase = (currentScroll * 0.015) % (Math.PI * 2);

      if (Math.abs(scrollPhase - prevPhase) > 0.0001) {
        prevPhase = scrollPhase;

        // 1. Draw unified base text "ihatebaselines." on white background
        offCtx.fillStyle = "#ffffff";
        offCtx.fillRect(0, 0, W, H);

        offCtx.fillStyle = "#171b20";
        offCtx.font = "800 32px 'JetBrains Mono', monospace";
        offCtx.textAlign = "left";
        offCtx.textBaseline = "middle";

        offCtx.fillText("ihatebaselines.", 10, H / 2);

        const baseImgData = offCtx.getImageData(0, 0, W, H);
        const basePixels = baseImgData.data;

        // 2. Sinusoidal wave remap
        const remappedR = new Uint8Array(W * H);
        const remappedG = new Uint8Array(W * H);
        const remappedB = new Uint8Array(W * H);

        const amp = 6;
        const freq = 0.08;

        for (let y = 0; y < H; y++) {
          const row = y * W;
          for (let x = 0; x < W; x++) {
            const srcX = Math.round(x + amp * Math.sin(freq * y + scrollPhase));
            const srcY = y;

            const rx = reflect(srcX, W);
            const ry = reflect(srcY, H);
            const idx = (ry * W + rx) * 4;

            remappedR[row + x] = basePixels[idx];
            remappedG[row + x] = basePixels[idx + 1];
            remappedB[row + x] = basePixels[idx + 2];
          }
        }

        // 3. Channel rolls
        R = remappedR;
        G = remappedG;
        B = remappedB;

        B = rollX(B, 15);
        B = rollX(R, -15);
        R = rollX(G, -15);
        B = rollX(G, 15);

        R = rollY(B, 5);
        G = rollY(G, 2);
        R = rollY(R, -5);
        G = rollY(R, 5);

        // 4. Output composite
        const outImgData = offCtx.createImageData(W, H);
        const outPixels = outImgData.data;

        for (let i = 0; i < W * H; i++) {
          const p = i * 4;
          const r_val = R[i];
          const g_val = G[i];
          const b_val = B[i];

          outPixels[p] = r_val;
          outPixels[p + 1] = g_val;
          outPixels[p + 2] = b_val;

          // Pure white background becomes transparent so it blends perfectly
          if (r_val > 245 && g_val > 245 && b_val > 245) {
            outPixels[p + 3] = 0;
          } else {
            outPixels[p + 3] = 255;
          }
        }
        offCtx.putImageData(outImgData, 0, 0);

        // 5. Draw pixelated on main canvas
        canvas.width = canvas.parentElement?.clientWidth || 580;
        canvas.height = canvas.parentElement?.clientHeight || 95;

        ctx.imageSmoothingEnabled = false;
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(offscreen, 0, 0, canvas.width, canvas.height);
      }

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      window.removeEventListener("scroll", handleScroll);
      cancelAnimationFrame(animId);
    };
  }, [isGlitch]);

  // If not glitch mode (or before mount), render clean text in site green rgb(63, 116, 115)
  if (!mounted || !isGlitch) {
    return (
      <h1
        className="home-title"
        style={{
          color: "rgb(63, 116, 115)",
          whiteSpace: "nowrap",
          letterSpacing: "-0.08em",
        }}
      >
        ihatebaselines<span className="title-period">.</span>
      </h1>
    );
  }

  // Glitched mode: render unified animated glitch canvas
  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        maxWidth: "600px",
        height: "clamp(60px, 9vw, 95px)",
        margin: "18px 0 16px",
      }}
    >
      <canvas
        ref={canvasRef}
        style={{
          display: "block",
          width: "100%",
          height: "100%",
          imageRendering: "pixelated",
        }}
        aria-label="ihatebaselines."
      />
    </div>
  );
}

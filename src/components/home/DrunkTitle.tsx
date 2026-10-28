"use client";

import { useEffect, useRef } from "react";

export default function DrunkTitle() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    // Grid sizes: low-res grid for pixelation
    const W = 320;
    const H = 160;

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
      // Lenis smooth scroll momentum interpolation
      currentScroll += (targetScroll - currentScroll) * 0.085;

      // When static (no scroll), phase is fixed! When scrolling, it ripples!
      const scrollPhase = (currentScroll * 0.012) % (Math.PI * 2);

      if (Math.abs(scrollPhase - prevPhase) > 0.0001) {
        prevPhase = scrollPhase;

        // 1. Draw base text "i hate baselines." on white background
        offCtx.fillStyle = "#ffffff";
        offCtx.fillRect(0, 0, W, H);

        offCtx.fillStyle = "#171b20"; // Dark site text color
        offCtx.font = "800 36px 'JetBrains Mono', monospace";
        offCtx.textAlign = "left";
        offCtx.textBaseline = "top";

        offCtx.fillText("i hate", 10, 16);
        offCtx.fillText("baselines.", 10, 68);

        const baseImgData = offCtx.getImageData(0, 0, W, H);
        const basePixels = baseImgData.data;

        // 2. Sinusoidal wave remap with BORDER_REFLECT
        const remappedR = new Uint8Array(W * H);
        const remappedG = new Uint8Array(W * H);
        const remappedB = new Uint8Array(W * H);

        const amp = 8;
        const freq = 0.07;

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

        // 3. Exact NP.ROLL from the notebook scaled to 320x160
        R = remappedR;
        G = remappedG;
        B = remappedB;

        B = rollX(B, 18);
        B = rollX(R, -18);
        R = rollX(G, -18);
        B = rollX(G, 18);

        R = rollY(B, 7);
        G = rollY(G, 2);

        R = rollY(R, -7);
        G = rollY(R, 7);
        G = rollY(R, -4);
        R = rollY(R, 10);

        // 4. Put into output ImageData with transparent background
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

          // Pure white background becomes transparent so it blends perfectly onto site theme
          if (r_val > 245 && g_val > 245 && b_val > 245) {
            outPixels[p + 3] = 0;
          } else {
            outPixels[p + 3] = 255;
          }
        }
        offCtx.putImageData(outImgData, 0, 0);

        // 5. Draw pixelated on main canvas
        canvas.width = canvas.parentElement?.clientWidth || 550;
        canvas.height = canvas.parentElement?.clientHeight || 240;

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
  }, []);

  return (
    <div style={{ position: "relative", width: "100%", maxWidth: "580px", height: "180px", margin: "16px 0 20px" }}>
      <canvas
        ref={canvasRef}
        style={{
          display: "block",
          width: "100%",
          height: "100%",
          imageRendering: "pixelated",
        }}
        aria-label="i hate baselines."
      />
    </div>
  );
}

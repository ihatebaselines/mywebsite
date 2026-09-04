"use client";

import { useRef, useState, useEffect } from "react";
import styles from "@/app/page.module.css";

const QUIPS = [
  "noot noot! :))",
  "waving at zero baselines 👋",
  "you moved me! :D",
  "looking for baselines...",
  "loss: 0.00",
  "keep building.",
];

export default function DraggableWavingPenguin() {
  const [pos, setPos] = useState({ x: 0, y: 0 });
  const [rotate, setRotate] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const [speech, setSpeech] = useState<string | null>(null);

  const dragStartRef = useRef<{
    startX: number;
    startY: number;
    initialX: number;
    initialY: number;
    pointerId: number;
    lastX: number;
    lastTime: number;
    distance: number;
  } | null>(null);

  const speechTimerRef = useRef<NodeJS.Timeout | null>(null);

  const showQuip = (text?: string) => {
    if (speechTimerRef.current) clearTimeout(speechTimerRef.current);
    const chosen =
      text || QUIPS[Math.floor(Math.random() * QUIPS.length)];
    setSpeech(chosen);
    speechTimerRef.current = setTimeout(() => {
      setSpeech(null);
    }, 2600);
  };

  const handlePointerDown = (e: React.PointerEvent<HTMLButtonElement>) => {
    if (e.button !== 0) return;
    e.preventDefault();
    e.stopPropagation();

    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      // ignore
    }

    dragStartRef.current = {
      startX: e.clientX,
      startY: e.clientY,
      initialX: pos.x,
      initialY: pos.y,
      pointerId: e.pointerId,
      lastX: e.clientX,
      lastTime: performance.now(),
      distance: 0,
    };
    setIsDragging(true);
  };

  const handlePointerMove = (e: React.PointerEvent<HTMLButtonElement>) => {
    const drag = dragStartRef.current;
    if (!drag || drag.pointerId !== e.pointerId) return;

    const deltaX = e.clientX - drag.startX;
    const deltaY = e.clientY - drag.startY;
    drag.distance = Math.hypot(deltaX, deltaY);

    const now = performance.now();
    const dt = Math.max(16, now - drag.lastTime);
    const vx = (e.clientX - drag.lastX) / dt;
    drag.lastX = e.clientX;
    drag.lastTime = now;

    const targetRot = Math.max(-20, Math.min(20, vx * 25));

    setPos({
      x: drag.initialX + deltaX,
      y: drag.initialY + deltaY,
    });
    setRotate((prev) => prev * 0.7 + targetRot * 0.3);
  };

  const handlePointerUp = (e: React.PointerEvent<HTMLButtonElement>) => {
    const drag = dragStartRef.current;
    if (!drag || drag.pointerId !== e.pointerId) return;

    try {
      e.currentTarget.releasePointerCapture(e.pointerId);
    } catch {
      // ignore
    }

    let droppedOnCard = false;
    if (typeof document !== "undefined") {
      const elementsUnder = document.elementsFromPoint(e.clientX, e.clientY);
      const isOverCard = elementsUnder.some((el) =>
        el.getAttribute("data-card") !== null ||
        el.getAttribute("data-project-card") !== null ||
        el.classList.toString().includes("projectCard") ||
        el.classList.toString().includes("editorial")
      );

      if (isOverCard && drag.distance > 10) {
        droppedOnCard = true;
        showQuip("code review initiated. 🐧");
        import("@/lib/progression").then((m) => m.unlockAchievement(3));
      }
    }

    if (!droppedOnCard) {
      if (drag.distance < 6) {
        showQuip();
      } else {
        if (Math.random() < 0.6) {
          showQuip();
        }
      }
    }

    dragStartRef.current = null;
    setIsDragging(false);
    setRotate(0);
  };

  const handleDoubleClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setPos({ x: 0, y: 0 });
    setRotate(0);
    showQuip("reset to baseline!");
  };

  useEffect(() => {
    return () => {
      if (speechTimerRef.current) clearTimeout(speechTimerRef.current);
    };
  }, []);

  return (
    <div className={styles.projectsPinguWrapNew} title="Drag me anywhere! (Double click to reset)">
      <button
        type="button"
        className={`${styles.draggableWavingPinguBtn} ${isDragging ? styles.isGrabbing : ""}`}
        style={{
          transform: `translate3d(${pos.x}px, ${pos.y}px, 0) rotate(${rotate}deg)`,
          transition: isDragging ? "none" : "transform 0.3s cubic-bezier(0.22, 1, 0.36, 1)",
        }}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
        onDoubleClick={handleDoubleClick}
        aria-label="Draggable waving penguin (Double-click to reset)"
      >
        <img
          src="/images/pingu-waving.png"
          alt="Waving Pingu"
          className={styles.projectsPinguImgNew}
          draggable={false}
          loading="lazy"
        />

        {speech && (
          <div className={styles.pinguSpeechBubble} role="status">
            {speech}
          </div>
        )}
      </button>
    </div>
  );
}

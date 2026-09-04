"use client";

import { useEffect, useRef, useState } from "react";
import styles from "@/app/page.module.css";

interface Pingu {
  id: number;
  x: number; // percentage of stage width
  y: number; // percentage of stage height
  size: number;
  rotate: number;
  img: string;
  alt: string;
  parallaxFactor: number;
}

const INITIAL_PINGUS: Pingu[] = [
  {
    id: 1,
    x: 68,
    y: 46,
    size: 210,
    rotate: -4,
    img: "/images/pingu-standing.png",
    alt: "Pingu standing with crossed arms",
    parallaxFactor: 0.12,
  },
  {
    id: 2,
    x: 8,
    y: 52,
    size: 155,
    rotate: 8,
    img: "/images/pingu-waving.png",
    alt: "Pingu waving",
    parallaxFactor: -0.08,
  },
  {
    id: 3,
    x: 75,
    y: 10,
    size: 140,
    rotate: 6,
    img: "/images/pingu-chair.png",
    alt: "Pingu sitting on chair",
    parallaxFactor: 0.06,
  },
  {
    id: 4,
    x: 14,
    y: 16,
    size: 125,
    rotate: -10,
    img: "/images/pingu-trumpet.png",
    alt: "Pingu looking through horn",
    parallaxFactor: -0.1,
  },
];

export default function PenguinDraggable() {
  const stageRef = useRef<HTMLDivElement>(null);
  const [pingus, setPingus] = useState<Pingu[]>(INITIAL_PINGUS);
  const pingusRef = useRef<Pingu[]>(INITIAL_PINGUS);
  const [activeDragId, setActiveDragId] = useState<number | null>(null);
  const [scrollY, setScrollY] = useState(0);

  // Easter egg: penguin click counter
  const [clickCount, setClickCount] = useState(0);
  const [speech, setSpeech] = useState<{ text: string; pinguId: number } | null>(null);
  const speechTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const dragRef = useRef<{
    id: number;
    pointerId: number;
    startX: number;
    startY: number;
    initialPinguX: number;
    initialPinguY: number;
    distance: number;
    lastX: number;
    lastTime: number;
  } | null>(null);

  useEffect(() => {
    pingusRef.current = pingus;
  }, [pingus]);

  // Restrained scroll parallax for non-dragged penguins
  useEffect(() => {
    if (typeof window === "undefined") return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    let ticking = false;
    const handleScroll = () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          setScrollY(window.scrollY);
          ticking = false;
        });
        ticking = true;
      }
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const showSpeechBubble = (text: string, pinguId: number) => {
    if (speechTimeoutRef.current) clearTimeout(speechTimeoutRef.current);
    setSpeech({ text, pinguId });
    speechTimeoutRef.current = setTimeout(() => setSpeech(null), 3000);
  };

  const handlePinguClick = (pinguId: number) => {
    setClickCount((prev) => {
      const next = prev + 1;
      if (next === 10) {
        showSpeechBubble("click_count = 10\nproductivity = 0", pinguId);
      } else if (next === 1) {
        showSpeechBubble("noot noot! :))", pinguId);
      } else if (next === 5) {
        showSpeechBubble("still clicking?", pinguId);
      } else if (next === 20) {
        showSpeechBubble("baseline unbroken.", pinguId);
      }
      return next;
    });
  };

  const handlePointerDown = (
    e: React.PointerEvent<HTMLButtonElement>,
    pingu: Pingu
  ) => {
    if (e.button !== 0) return;
    e.preventDefault();
    e.stopPropagation();

    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      // ignore
    }

    dragRef.current = {
      id: pingu.id,
      pointerId: e.pointerId,
      startX: e.clientX,
      startY: e.clientY,
      initialPinguX: pingu.x,
      initialPinguY: pingu.y,
      distance: 0,
      lastX: e.clientX,
      lastTime: performance.now(),
    };

    setActiveDragId(pingu.id);
  };

  const handlePointerMove = (e: React.PointerEvent<HTMLButtonElement>) => {
    const drag = dragRef.current;
    const stage = stageRef.current;
    if (!drag || drag.pointerId !== e.pointerId || !stage) return;

    e.preventDefault();
    e.stopPropagation();

    const rect = stage.getBoundingClientRect();
    if (rect.width === 0 || rect.height === 0) return;

    const deltaX = e.clientX - drag.startX;
    const deltaY = e.clientY - drag.startY;
    drag.distance = Math.hypot(deltaX, deltaY);

    const now = performance.now();
    const dt = Math.max(16, now - drag.lastTime);
    const vx = (e.clientX - drag.lastX) / dt;
    drag.lastX = e.clientX;
    drag.lastTime = now;

    const deltaPercentX = (deltaX / rect.width) * 100;
    const deltaPercentY = (deltaY / rect.height) * 100;

    const nextX = Math.min(92, Math.max(0, drag.initialPinguX + deltaPercentX));
    const nextY = Math.min(88, Math.max(0, drag.initialPinguY + deltaPercentY));

    const targetRot = Math.max(-20, Math.min(20, vx * 30));

    setPingus((current) =>
      current.map((p) =>
        p.id === drag.id
          ? {
              ...p,
              x: nextX,
              y: nextY,
              rotate: p.rotate * 0.8 + targetRot * 0.2,
            }
          : p
      )
    );
  };

  const handlePointerUp = (
    e: React.PointerEvent<HTMLButtonElement>,
    pingu: Pingu
  ) => {
    const drag = dragRef.current;
    if (!drag || drag.pointerId !== e.pointerId) return;

    try {
      e.currentTarget.releasePointerCapture(e.pointerId);
    } catch {
      // ignore
    }

    if (drag.distance < 6) {
      handlePinguClick(pingu.id);
    }

    dragRef.current = null;
    setActiveDragId(null);
  };

  return (
    <div
      ref={stageRef}
      className={styles.pinguStageRoot}
      aria-label="Interactive draggable penguins stage"
    >
      {pingus.map((p) => {
        const isDragging = activeDragId === p.id;
        const parallaxY = isDragging ? 0 : scrollY * p.parallaxFactor;

        return (
          <div
            key={p.id}
            className={`${styles.pinguWrapper} ${isDragging ? styles.isGrabbing : ""}`}
            style={{
              left: `${p.x}%`,
              top: `${p.y}%`,
              width: `${p.size}px`,
              transform: `translate3d(0, ${parallaxY}px, 0) rotate(${p.rotate}deg)`,
              zIndex: isDragging ? 50 : 31,
              transition: isDragging ? "none" : "transform 0.15s ease-out",
            }}
          >
            <button
              type="button"
              className={styles.pinguBtn}
              onPointerDown={(e) => handlePointerDown(e, p)}
              onPointerMove={handlePointerMove}
              onPointerUp={(e) => handlePointerUp(e, p)}
              onPointerCancel={(e) => handlePointerUp(e, p)}
              aria-label={`Drag or click ${p.alt}`}
            >
              <img
                src={p.img}
                alt={p.alt}
                className={styles.pinguImage}
                draggable={false}
                loading="eager"
              />
            </button>

            {/* Speech bubble easter egg */}
            {speech && speech.pinguId === p.id && (
              <div className={styles.pinguSpeechBubble}>
                {speech.text.split("\n").map((line, idx) => (
                  <span key={idx}>
                    {line}
                    <br />
                  </span>
                ))}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

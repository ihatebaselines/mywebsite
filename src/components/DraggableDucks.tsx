"use client";

import { useEffect, useRef, useState } from "react";
import styles from "@/app/page.module.css";

type Cat = {
  id: number;
  x: number;
  y: number;
  size: number;
  rotate: number;
  img: string;
};

type DragState = {
  id: number;
  pointerId: number;
  dx: number;
  dy: number;
};

const initialCats: Cat[] = [
  { id: 1, x: 65, y: 48, size: 220, rotate: -5, img: "/images/pingu-standing.png" },
  { id: 2, x: 7,  y: 55, size: 155, rotate: 10, img: "/images/pingu-waving.png" },
  { id: 3, x: 74, y: 10, size: 140, rotate: 8,  img: "/images/pingu-chair.png" },
  { id: 4, x: 16, y: 16, size: 125, rotate: -12, img: "/images/pingu-trumpet.png" },
];

export default function DraggableDucks() {
  const stageRef = useRef<HTMLDivElement>(null);
  const dragRef = useRef<DragState | null>(null);
  const catsRef = useRef(initialCats);
  const catElementsRef = useRef(new Map<number, HTMLButtonElement>());
  const [cats, setCats] = useState(initialCats);
  const clickCountRef = useRef(0);
  const [speech, setSpeech] = useState<{ text: string; catId: number } | null>(null);

  useEffect(() => {
    catsRef.current = cats;
  }, [cats]);

  function moveCat(clientX: number, clientY: number) {
    const drag = dragRef.current;
    const stage = stageRef.current;
    if (!drag || !stage) return;

    const rect = stage.getBoundingClientRect();
    const nextX = ((clientX - rect.left - drag.dx) / rect.width) * 100;
    const nextY = ((clientY - rect.top - drag.dy) / rect.height) * 100;

    setCats((current) =>
      current.map((cat) =>
        cat.id === drag.id
          ? {
              ...cat,
              x: Math.min(88, Math.max(0, nextX)),
              y: Math.min(78, Math.max(0, nextY)),
              rotate: cat.rotate + (nextX - cat.x) * 0.025,
            }
          : cat,
      ),
    );
  }

  function findCatAtPoint(clientX: number, clientY: number) {
    for (const cat of catsRef.current.toReversed()) {
      const element = catElementsRef.current.get(cat.id);
      if (!element) continue;

      const rect = element.getBoundingClientRect();
      const isInside =
        clientX >= rect.left &&
        clientX <= rect.right &&
        clientY >= rect.top &&
        clientY <= rect.bottom;

      if (isInside) {
        return cat;
      }
    }

    return null;
  }

  function startDrag(cat: Cat, pointerId: number, clientX: number, clientY: number) {
    const stage = stageRef.current;
    if (!stage) return;

    const rect = stage.getBoundingClientRect();
    const left = (cat.x / 100) * rect.width;
    const top = (cat.y / 100) * rect.height;

    dragRef.current = {
      id: cat.id,
      pointerId,
      dx: clientX - rect.left - left,
      dy: clientY - rect.top - top,
    };
  }

  useEffect(() => {
    let animFrameId: number | null = null;
    let pendingPoint: { clientX: number; clientY: number } | null = null;

    function processDrag() {
      if (pendingPoint && dragRef.current) {
        moveCat(pendingPoint.clientX, pendingPoint.clientY);
      }
      animFrameId = null;
    }

    function onPointerMove(event: PointerEvent) {
      const drag = dragRef.current;
      if (!drag || drag.pointerId !== event.pointerId) return;

      pendingPoint = { clientX: event.clientX, clientY: event.clientY };
      if (!animFrameId) {
        animFrameId = requestAnimationFrame(processDrag);
      }
    }

    function onPointerEnd(event: PointerEvent) {
      const drag = dragRef.current;
      if (!drag || drag.pointerId !== event.pointerId) return;

      if (animFrameId) {
        cancelAnimationFrame(animFrameId);
        animFrameId = null;
      }
      dragRef.current = null;
      pendingPoint = null;

      window.removeEventListener("pointermove", onPointerMove);
      window.removeEventListener("pointerup", onPointerEnd);
      window.removeEventListener("pointercancel", onPointerEnd);
    }

    function onPointerDown(event: PointerEvent) {
      if (event.button !== 0) return;

      const target = event.target;
      if (target instanceof Element) {
        const isCatButton = Boolean(target.closest("[data-cat-button]"));
        const isInteractive = Boolean(
          target.closest("a, input, textarea, select, [data-no-cat-drag]"),
        );
        const isOtherButton = Boolean(target.closest("button")) && !isCatButton;

        if (isInteractive || isOtherButton) {
          return;
        }
      }

      const cat = findCatAtPoint(event.clientX, event.clientY);
      if (!cat) return;

      event.preventDefault();
      event.stopPropagation();

      // Easter egg: track penguin clicks
      clickCountRef.current++;
      const count = clickCountRef.current;
      if (count === 5) {
        setSpeech({ text: "stop clicking me.", catId: cat.id });
        setTimeout(() => setSpeech(null), 2500);
      } else if (count === 6) {
        setSpeech({ text: "seriously.", catId: cat.id });
        setTimeout(() => setSpeech(null), 2500);
      } else if (count >= 10) {
        setSpeech({ text: `click_count = ${count}\nproductivity = 0`, catId: cat.id });
        setTimeout(() => setSpeech(null), 3000);
      }

      startDrag(cat, event.pointerId, event.clientX, event.clientY);

      // Only attach move/up listeners during an active drag!
      window.addEventListener("pointermove", onPointerMove, { passive: true });
      window.addEventListener("pointerup", onPointerEnd, { passive: true });
      window.addEventListener("pointercancel", onPointerEnd, { passive: true });
    }

    const stageEl = stageRef.current;
    if (stageEl) {
      stageEl.addEventListener("pointerdown", onPointerDown, { passive: false });
    }

    return () => {
      if (animFrameId) cancelAnimationFrame(animFrameId);
      if (stageEl) stageEl.removeEventListener("pointerdown", onPointerDown);
      window.removeEventListener("pointermove", onPointerMove);
      window.removeEventListener("pointerup", onPointerEnd);
      window.removeEventListener("pointercancel", onPointerEnd);
    };
  }, []);

  return (
    <div ref={stageRef} className={styles.duckStage} aria-label="Draggable Pingus">
      {cats.map((cat) => (
        <button
          type="button"
          key={cat.id}
          ref={(element) => {
            if (element) {
              catElementsRef.current.set(cat.id, element);
            } else {
              catElementsRef.current.delete(cat.id);
            }
          }}
          data-cat-button
          className={styles.draggableDuck}
          aria-label="Drag Pingu"
          style={{
            left: `${cat.x}%`,
            top: `${cat.y}%`,
            width: `clamp(${cat.size * 0.45}px, ${cat.size / 12}vw, ${cat.size}px)`,
            transform: `rotate(${cat.rotate}deg)`,
          }}
        >
          <img
            src={cat.img}
            alt=""
            draggable={false}
            className={styles.draggableDuckImage}
            loading="lazy"
            decoding="async"
          />
          {speech && speech.catId === cat.id && (
            <div
              style={{
                position: "absolute",
                top: "-40px",
                left: "50%",
                transform: "translateX(-50%)",
                background: "#1e1b1b",
                border: "1px solid var(--border)",
                color: "var(--foreground)",
                fontFamily: "var(--font-jetbrains-mono, monospace)",
                fontSize: "11px",
                padding: "4px 8px",
                borderRadius: "4px",
                whiteSpace: "pre-line",
                pointerEvents: "none",
                zIndex: 100,
                boxShadow: "0 4px 12px rgba(0,0,0,0.5)",
                lineHeight: 1.3,
                textAlign: "center",
              }}
            >
              {speech.text}
            </div>
          )}
        </button>
      ))}
    </div>
  );
}

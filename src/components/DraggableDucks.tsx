"use client";

import { useEffect, useRef, useState } from "react";
import styles from "@/app/page.module.css";

type Cat = {
  id: number;
  x: number;
  y: number;
  size: number;
  rotate: number;
};

type DragState = {
  id: number;
  pointerId: number;
  dx: number;
  dy: number;
};

const initialCats: Cat[] = [
  { id: 1, x: 68, y: 52, size: 210, rotate: -7 },
  { id: 2, x: 9, y: 58, size: 140, rotate: 12 },
  { id: 3, x: 76, y: 14, size: 120, rotate: 9 },
  { id: 4, x: 19, y: 20, size: 105, rotate: -14 },
];

export default function DraggableDucks() {
  const stageRef = useRef<HTMLDivElement>(null);
  const dragRef = useRef<DragState | null>(null);
  const catsRef = useRef(initialCats);
  const catElementsRef = useRef(new Map<number, HTMLButtonElement>());
  const [cats, setCats] = useState(initialCats);

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
      startDrag(cat, event.pointerId, event.clientX, event.clientY);
    }

    function onPointerMove(event: PointerEvent) {
      const drag = dragRef.current;
      if (!drag || drag.pointerId !== event.pointerId) return;

      event.preventDefault();
      moveCat(event.clientX, event.clientY);
    }

    function onPointerEnd(event: PointerEvent) {
      const drag = dragRef.current;
      if (!drag || drag.pointerId !== event.pointerId) return;

      event.preventDefault();
      dragRef.current = null;
    }

    document.addEventListener("pointerdown", onPointerDown, {
      capture: true,
      passive: false,
    });
    document.addEventListener("pointermove", onPointerMove, { passive: false });
    document.addEventListener("pointerup", onPointerEnd, { passive: false });
    document.addEventListener("pointercancel", onPointerEnd, { passive: false });

    return () => {
      document.removeEventListener("pointerdown", onPointerDown, { capture: true });
      document.removeEventListener("pointermove", onPointerMove);
      document.removeEventListener("pointerup", onPointerEnd);
      document.removeEventListener("pointercancel", onPointerEnd);
    };
  }, []);

  return (
    <div ref={stageRef} className={styles.duckStage} aria-label="Draggable cats">
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
          aria-label="Drag cat"
          style={{
            left: `${cat.x}%`,
            top: `${cat.y}%`,
            width: `clamp(${cat.size * 0.45}px, ${cat.size / 12}vw, ${cat.size}px)`,
            transform: `rotate(${cat.rotate}deg)`,
          }}
        >
          <img
            src="/images/portfolio-cat.png"
            alt=""
            draggable={false}
            className={styles.draggableDuckImage}
          />
        </button>
      ))}
    </div>
  );
}

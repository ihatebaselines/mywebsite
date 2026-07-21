"use client";

import { useEffect, useRef } from "react";
import styles from "@/app/page.module.css";

export default function CustomCursor() {
  const dotRef = useRef<HTMLDivElement>(null);
  const ringRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Only on desktop / pointer device
    if (window.matchMedia("(hover: none)").matches) return;
    if (window.matchMedia("(max-width: 760px)").matches) return;

    const dot = dotRef.current;
    const ring = ringRef.current;
    if (!dot || !ring) return;

    let mouseX = -200;
    let mouseY = -200;
    let ringX = -200;
    let ringY = -200;
    let raf: number;

    function onMove(e: PointerEvent) {
      mouseX = e.clientX;
      mouseY = e.clientY;
    }

    function onEnterLink() {
      dot?.classList.add(styles.cursorDotHover);
      ring?.classList.add(styles.cursorRingHover);
    }

    function onLeaveLink() {
      dot?.classList.remove(styles.cursorDotHover);
      ring?.classList.remove(styles.cursorRingHover);
    }

    function onEnterButton() {
      dot?.classList.add(styles.cursorDotClick);
      ring?.classList.add(styles.cursorRingClick);
    }

    function onLeaveButton() {
      dot?.classList.remove(styles.cursorDotClick);
      ring?.classList.remove(styles.cursorRingClick);
    }

    // Delegate hover detection
    function onOver(e: MouseEvent) {
      const target = e.target as Element;
      if (target.closest("button, [role=button]")) {
        onEnterButton();
      } else if (target.closest("a")) {
        onEnterLink();
      } else {
        onLeaveLink();
        onLeaveButton();
      }
    }

    function tick() {
      // Snap dot to cursor instantly
      dot!.style.transform = `translate(${mouseX}px, ${mouseY}px)`;

      // Ring lerps behind
      ringX += (mouseX - ringX) * 0.12;
      ringY += (mouseY - ringY) * 0.12;
      ring!.style.transform = `translate(${ringX}px, ${ringY}px)`;

      raf = requestAnimationFrame(tick);
    }

    document.addEventListener("pointermove", onMove);
    document.addEventListener("mouseover", onOver);
    raf = requestAnimationFrame(tick);

    // Hide native cursor on body
    document.body.classList.add(styles.hideCursor);

    return () => {
      document.removeEventListener("pointermove", onMove);
      document.removeEventListener("mouseover", onOver);
      cancelAnimationFrame(raf);
      document.body.classList.remove(styles.hideCursor);
    };
  }, []);

  return (
    <>
      <div ref={dotRef} className={styles.cursorDot} aria-hidden="true" />
      <div ref={ringRef} className={styles.cursorRing} aria-hidden="true" />
    </>
  );
}

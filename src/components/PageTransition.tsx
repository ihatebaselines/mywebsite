"use client";

import { useEffect, useRef } from "react";
import { usePathname } from "next/navigation";
import styles from "@/app/page.module.css";

export default function PageTransition() {
  const overlayRef = useRef<HTMLDivElement>(null);
  const pathname = usePathname();
  const prevPathRef = useRef(pathname);

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    const overlay = overlayRef.current;
    if (!overlay) return;

    if (prevPathRef.current !== pathname) {
      prevPathRef.current = pathname;
      // Flash in then fade out
      overlay.classList.remove(styles.transitionOut);
      overlay.classList.add(styles.transitionIn);

      const t = setTimeout(() => {
        overlay.classList.remove(styles.transitionIn);
        overlay.classList.add(styles.transitionOut);
      }, 220);

      return () => clearTimeout(t);
    }

    // Initial page load fade-in
    overlay.classList.add(styles.transitionIn);
    const t = setTimeout(() => {
      overlay.classList.remove(styles.transitionIn);
      overlay.classList.add(styles.transitionOut);
    }, 300);

    return () => clearTimeout(t);
  }, [pathname]);

  return (
    <div
      ref={overlayRef}
      className={`${styles.pageTransition} ${styles.transitionIn}`}
      aria-hidden="true"
    />
  );
}

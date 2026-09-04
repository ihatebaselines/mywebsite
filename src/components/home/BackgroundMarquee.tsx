"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import styles from "@/app/page.module.css";

export default function BackgroundMarquee() {
  const containerRef = useRef<HTMLDivElement>(null);
  const row1Ref = useRef<HTMLDivElement>(null);
  const row2Ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (typeof window === "undefined") return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    gsap.registerPlugin(ScrollTrigger);

    const container = containerRef.current;
    const row1 = row1Ref.current;
    const row2 = row2Ref.current;
    if (!container || !row1 || !row2) return;

    const ctx = gsap.context(() => {
      gsap.to(row1, {
        xPercent: -12,
        ease: "none",
        scrollTrigger: {
          trigger: container,
          start: "top bottom",
          end: "bottom top",
          scrub: 0.5,
        },
      });

      gsap.to(row2, {
        xPercent: 12,
        ease: "none",
        scrollTrigger: {
          trigger: container,
          start: "top bottom",
          end: "bottom top",
          scrub: 0.5,
        },
      });
    }, container);

    return () => ctx.revert();
  }, []);

  const stream1 =
    "IHATEBASELINES · RESEARCH · ALGORITHMS · IHATEBASELINES · RESEARCH · ALGORITHMS · ";
  const stream2 =
    "OPEN SOURCE · MACHINE LEARNING · EXPERIMENTS · OPEN SOURCE · MACHINE LEARNING · EXPERIMENTS · ";

  return (
    <div
      ref={containerRef}
      className={styles.marqueeStream}
      aria-hidden="true"
    >
      <div ref={row1Ref} className={styles.marqueeRow}>
        <span>{stream1}</span>
        <span>{stream1}</span>
      </div>
      <div
        ref={row2Ref}
        className={`${styles.marqueeRow} ${styles.marqueeRowReverse}`}
      >
        <span>{stream2}</span>
        <span>{stream2}</span>
      </div>
    </div>
  );
}

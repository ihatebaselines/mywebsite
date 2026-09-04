"use client";

import React, { useRef, useEffect } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import styles from "@/app/page.module.css";

export default function ScrollTextLines() {
  const containerRef = useRef<HTMLDivElement>(null);
  const line1Ref = useRef<HTMLDivElement>(null);
  const line2Ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return;
    }
    gsap.registerPlugin(ScrollTrigger);

    const container = containerRef.current;
    const line1 = line1Ref.current;
    const line2 = line2Ref.current;
    if (!container || !line1 || !line2) return;

    const ctx = gsap.context(() => {
      gsap.to(line1, {
        xPercent: -14,
        ease: "none",
        scrollTrigger: {
          trigger: container,
          start: "top bottom",
          end: "bottom top",
          scrub: 0.4,
        },
      });

      gsap.to(line2, {
        xPercent: 14,
        ease: "none",
        scrollTrigger: {
          trigger: container,
          start: "top bottom",
          end: "bottom top",
          scrub: 0.4,
        },
      });
    }, container);

    return () => ctx.revert();
  }, []);

  const stream1 = "IHATEBASELINES · RESEARCH · ALGORITHMS · IHATEBASELINES · RESEARCH · ALGORITHMS · ";
  const stream2 = "OPEN SOURCE · MACHINE · LEARNING · OPEN SOURCE · MACHINE · LEARNING · ";

  return (
    <div ref={containerRef} className={styles.scrollTextStream} aria-hidden="true">
      <div ref={line1Ref} className={styles.scrollTextLine}>
        <span>{stream1}</span>
        <span>{stream1}</span>
      </div>
      <div ref={line2Ref} className={`${styles.scrollTextLine} ${styles.scrollTextLineReverse}`}>
        <span>{stream2}</span>
        <span>{stream2}</span>
      </div>
    </div>
  );
}

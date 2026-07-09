"use client";

import { useEffect, useRef } from "react";
import Link from "next/link";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import type { WorkItem } from "@/content/work";
import styles from "@/app/page.module.css";

export default function HorizontalShowcase({ items }: { items: WorkItem[] }) {
  const sectionRef = useRef<HTMLElement>(null);
  const trackRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (
      window.matchMedia("(prefers-reduced-motion: reduce)").matches ||
      window.matchMedia("(max-width: 860px)").matches
    ) {
      return;
    }

    gsap.registerPlugin(ScrollTrigger);

    const section = sectionRef.current;
    const track = trackRef.current;
    if (!section || !track) return;

    const tween = gsap.to(track, {
      x: () => -(track.scrollWidth - window.innerWidth + 48),
      ease: "none",
      scrollTrigger: {
        trigger: section,
        pin: true,
        scrub: 1,
        start: "top top",
        end: () => `+=${track.scrollWidth}`,
        invalidateOnRefresh: true,
      },
    });

    const cards = gsap.utils.toArray<HTMLElement>(`.${styles.horizontalCard}`);
    const triggers: ScrollTrigger[] = [];

    cards.forEach((card) => {
      const st = ScrollTrigger.create({
        trigger: card,
        containerAnimation: tween,
        start: "left center",
        end: "right center",
        toggleClass: styles.horizontalCardActive,
      });
      triggers.push(st);
    });

    return () => {
      triggers.forEach(t => t.kill());
      tween.kill();
    };
  }, []);

  return (
    <section ref={sectionRef} className={styles.horizontalShowcase}>
      <div className={styles.horizontalIntro}>
        <p>Scroll down(:</p>
        <h2 data-split-heading>Projects</h2>
      </div>

      <div ref={trackRef} className={styles.horizontalTrack}>
        {items.map((item, index) => (
          <Link
            className={styles.horizontalCard}
            href={`/work/${item.slug}`}
            key={`${item.slug}-lane`}
          >
            <span>{String(index + 1).padStart(2, "0")}</span>
            <div className={styles.horizontalImage}>
              <img src={item.image} alt="" loading="lazy" decoding="async" />
            </div>
            <div>
              <p>
                {item.tag} / {item.date}
              </p>
              <h3>{item.title}</h3>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}

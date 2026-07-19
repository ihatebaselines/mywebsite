"use client";

import { useEffect } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import SplitType from "split-type";

export default function PremiumEffects() {
  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return;
    }

    gsap.registerPlugin(ScrollTrigger);

    if (window.matchMedia("(max-width: 760px)").matches) {
      return;
    }

    const title = document.querySelector("[data-hero-title]");
    const split = title ? new SplitType(title as HTMLElement, { types: "chars" }) : null;
    const headingSplits: SplitType[] = [];

    if (split?.chars?.length) {
      gsap.fromTo(
        split.chars,
        { yPercent: 115, opacity: 0, rotateX: -70, filter: "blur(10px)" },
        {
          yPercent: 0,
          opacity: 1,
          rotateX: 0,
          filter: "blur(0px)",
          duration: 0.9,
          ease: "power4.out",
          stagger: 0.025,
          delay: 0.1,
        },
      );
    }

    gsap.utils.toArray<HTMLElement>("[data-split-heading]").forEach((heading) => {
      const headingSplit = new SplitType(heading, { types: "words" });
      headingSplits.push(headingSplit);

      if (!headingSplit.words?.length) return;

      gsap.fromTo(
        headingSplit.words,
        { yPercent: 105, opacity: 0, filter: "blur(8px)" },
        {
          yPercent: 0,
          opacity: 1,
          filter: "blur(0px)",
          duration: 0.72,
          ease: "power4.out",
          stagger: 0.045,
          scrollTrigger: {
            trigger: heading,
            start: "top 82%",
            end: "bottom 18%",
            toggleActions: "play none none reverse",
          },
        },
      );
    });

    const revealItems = gsap.utils.toArray<HTMLElement>("[data-reveal]");
    revealItems.forEach((item) => {
      gsap.fromTo(
        item,
        { y: 42, opacity: 0, filter: "blur(8px)" },
        {
          y: 0,
          opacity: 1,
          filter: "blur(0px)",
          duration: 0.8,
          ease: "power3.out",
          scrollTrigger: {
            trigger: item,
            start: "top 84%",
            end: "bottom 16%",
            toggleActions: "play none none reverse",
          },
        },
      );
    });

    const clipItems = gsap.utils.toArray<HTMLElement>("[data-clip-reveal]");
    clipItems.forEach((item) => {
      gsap.fromTo(
        item,
        {
          clipPath: "inset(0% 100% 0% 0% round 8px)",
          filter: "blur(8px)",
          scale: 1.04,
        },
        {
          clipPath: "inset(0% 0% 0% 0% round 8px)",
          filter: "blur(0px)",
          scale: 1,
          duration: 0.95,
          ease: "expo.out",
          scrollTrigger: {
            trigger: item,
            start: "top 86%",
            end: "bottom 12%",
            toggleActions: "play none none reverse",
          },
        },
      );
    });

    const cards = gsap.utils.toArray<HTMLElement>("[data-card]");
    cards.forEach((card, index) => {
      gsap.fromTo(
        card,
        {
          y: 54,
          opacity: 0,
          scale: 0.97,
          clipPath: "inset(18% 0% 18% 0% round 8px)",
        },
        {
          y: 0,
          opacity: 1,
          scale: 1,
          clipPath: "inset(0% 0% 0% 0% round 8px)",
          duration: 0.65,
          delay: (index % 6) * 0.035,
          ease: "power3.out",
          scrollTrigger: {
            trigger: card,
            start: "top 90%",
            end: "bottom 8%",
            toggleActions: "play none none reverse",
          },
        },
      );
    });

    const cinematicBlocks = gsap.utils.toArray<HTMLElement>("[data-cinematic]");
    cinematicBlocks.forEach((block) => {
      const media = block.querySelector("img, iframe");

      gsap.fromTo(
        block,
        { "--line-scale": 0 },
        {
          "--line-scale": 1,
          duration: 0.9,
          ease: "power3.out",
          scrollTrigger: {
            trigger: block,
            start: "top 82%",
            end: "bottom 16%",
            toggleActions: "play none none reverse",
          },
        },
      );

      if (media) {
        gsap.to(media, {
          yPercent: -6,
          ease: "none",
          scrollTrigger: {
            trigger: block,
            start: "top bottom",
            end: "bottom top",
            scrub: 0.8,
          },
        });
      }
    });

    // ═══════════════════════════════════════════════════════
    // HERO 3D PLUNGE TRANSITION
    // ═══════════════════════════════════════════════════════
    const heroSection = document.querySelector("section[class*='hero']");
    const heroCopy = document.querySelector("div[class*='heroCopy']");
    const duckButtons = document.querySelectorAll("button[class*='draggableDuck']");
    const bentoGridSection = document.querySelector("#last-work");

    if (heroSection && heroCopy && bentoGridSection) {
      const bentoCards = bentoGridSection.querySelectorAll("[data-card]");

      const plungeTl = gsap.timeline({
        scrollTrigger: {
          trigger: heroSection,
          start: "top top",
          end: "+=140%",
          pin: true,
          pinSpacing: false, // Allows Bento Grid to scroll up underneath/over
          scrub: 1.5, // Smooth scrubbing
        }
      });

      // 1. Massive zoom-in and fade out of the text
      plungeTl.to(heroCopy, {
        scale: 12,
        opacity: 0,
        filter: "blur(20px)",
        ease: "power2.in",
        duration: 1
      }, 0);

      // 2. Ducks fly away
      duckButtons.forEach((duck, i) => {
        const xMove = i % 2 === 0 ? -250 : 250;
        const yMove = i < 2 ? -250 : 250;

        plungeTl.to(duck, {
          x: xMove,
          y: yMove,
          scale: 4,
          opacity: 0,
          rotate: xMove / 2,
          ease: "power2.in",
          duration: 1
        }, 0);
      });

      // 3. Assemble Bento Grid from depth
      if (bentoCards.length) {
        plungeTl.fromTo(bentoCards, {
          scale: 0.65,
          opacity: 0,
          y: 100,
          rotateX: 10
        }, {
          scale: 1,
          opacity: 1,
          y: 0,
          rotateX: 0,
          stagger: 0.08,
          ease: "power3.out",
          duration: 0.8
        }, 0.3); // Starts slightly after the zoom begins
      }
    }


    const rafId = requestAnimationFrame(() => {
      ScrollTrigger.refresh();
    });

    return () => {
      cancelAnimationFrame(rafId);
      ScrollTrigger.getAll().forEach((trigger) => trigger.kill());
      split?.revert();
      headingSplits.forEach((item) => item.revert());
    };
  }, []);

}

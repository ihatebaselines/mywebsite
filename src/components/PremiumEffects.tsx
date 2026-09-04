"use client";

import { useEffect } from "react";
import { usePathname } from "next/navigation";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import SplitType from "split-type";

export default function PremiumEffects() {
  const pathname = usePathname();

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return;
    }

    gsap.registerPlugin(ScrollTrigger);

    const isMobile = window.matchMedia("(max-width: 760px)").matches;
    const title = document.querySelector("[data-hero-title]");
    const headingSplits: SplitType[] = [];

    // ═══════════════════════════════════════════════════════
    // MOBILE ANIMATIONS — lightweight GPU-accelerated
    // ═══════════════════════════════════════════════════════
    if (isMobile) {
      // Hero title: word-by-word slide up
      const split = title ? new SplitType(title as HTMLElement, { types: "words" }) : null;

      if (split?.words?.length) {
        gsap.fromTo(
          split.words,
          { yPercent: 60, opacity: 0 },
          {
            yPercent: 0,
            opacity: 1,
            duration: 0.6,
            ease: "power3.out",
            stagger: 0.05,
            delay: 0.05,
          },
        );
      }

      // Section headings — word reveal on scroll
      gsap.utils.toArray<HTMLElement>("[data-split-heading]").forEach((heading) => {
        const headingSplit = new SplitType(heading, { types: "words" });
        headingSplits.push(headingSplit);
        if (!headingSplit.words?.length) return;

        gsap.fromTo(
          headingSplit.words,
          { yPercent: 60, opacity: 0 },
          {
            yPercent: 0,
            opacity: 1,
            duration: 0.5,
            ease: "power3.out",
            stagger: 0.04,
            scrollTrigger: {
              trigger: heading,
              start: "top 90%",
              toggleActions: "play none none reverse",
            },
          },
        );
      });

      // data-reveal — fade + slide up
      gsap.utils.toArray<HTMLElement>("[data-reveal]").forEach((item) => {
        gsap.fromTo(
          item,
          { y: 24, opacity: 0 },
          {
            y: 0,
            opacity: 1,
            duration: 0.5,
            ease: "power3.out",
            scrollTrigger: {
              trigger: item,
              start: "top 90%",
              toggleActions: "play none none reverse",
            },
          },
        );
      });

      // data-card — scale + fade pop-in
      gsap.utils.toArray<HTMLElement>("[data-card]").forEach((card, index) => {
        gsap.fromTo(
          card,
          { y: 24, opacity: 0, scale: 0.97 },
          {
            y: 0,
            opacity: 1,
            scale: 1,
            duration: 0.45,
            delay: (index % 4) * 0.03,
            ease: "power3.out",
            scrollTrigger: {
              trigger: card,
              start: "top 92%",
              toggleActions: "play none none reverse",
            },
          },
        );
      });

      const rafId = requestAnimationFrame(() => {
        ScrollTrigger.refresh();
      });

      return () => {
        cancelAnimationFrame(rafId);
        ScrollTrigger.getAll().forEach((trigger) => trigger.kill());
        split?.revert();
        headingSplits.forEach((item) => item.revert());
      };
    }

    // ═══════════════════════════════════════════════════════
    // DESKTOP FULL ANIMATIONS (smooth GPU accelerated)
    // ═══════════════════════════════════════════════════════

    const split = title ? new SplitType(title as HTMLElement, { types: "chars" }) : null;

    if (split?.chars?.length) {
      gsap.fromTo(
        split.chars,
        { yPercent: 90, opacity: 0, rotateX: -45 },
        {
          yPercent: 0,
          opacity: 1,
          rotateX: 0,
          duration: 0.75,
          ease: "power4.out",
          stagger: 0.02,
          delay: 0.08,
        },
      );
    }

    gsap.utils.toArray<HTMLElement>("[data-split-heading]").forEach((heading) => {
      const headingSplit = new SplitType(heading, { types: "words" });
      headingSplits.push(headingSplit);

      if (!headingSplit.words?.length) return;

      gsap.fromTo(
        headingSplit.words,
        { yPercent: 75, opacity: 0 },
        {
          yPercent: 0,
          opacity: 1,
          duration: 0.6,
          ease: "power4.out",
          stagger: 0.035,
          scrollTrigger: {
            trigger: heading,
            start: "top 86%",
            end: "bottom 14%",
            toggleActions: "play none none reverse",
          },
        },
      );
    });

    const revealItems = gsap.utils.toArray<HTMLElement>("[data-reveal]");
    revealItems.forEach((item) => {
      gsap.fromTo(
        item,
        { y: 32, opacity: 0 },
        {
          y: 0,
          opacity: 1,
          duration: 0.65,
          ease: "power3.out",
          scrollTrigger: {
            trigger: item,
            start: "top 86%",
            end: "bottom 14%",
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
          clipPath: "inset(0% 45% 0% 45% round 6px)",
          scale: 1.05,
          opacity: 0.5,
        },
        {
          clipPath: "inset(0% 0% 0% 0% round 6px)",
          scale: 1,
          opacity: 1,
          duration: 0.85,
          ease: "expo.out",
          scrollTrigger: {
            trigger: item,
            start: "top 90%",
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
          y: 36,
          opacity: 0,
          scale: 0.98,
        },
        {
          y: 0,
          opacity: 1,
          scale: 1,
          duration: 0.55,
          delay: (index % 6) * 0.025,
          ease: "power3.out",
          scrollTrigger: {
            trigger: card,
            start: "top 92%",
            end: "bottom 6%",
            toggleActions: "play none none reverse",
          },
        },
      );
    });

    // ═══════════════════════════════════════════════════════
    // SCROLL WORD REVEAL (for About Me / Editorial bios)
    // ═══════════════════════════════════════════════════════
    const wordRevealElements = gsap.utils.toArray<HTMLElement>("[data-word-reveal]");
    const wordSplits: SplitType[] = [];

    wordRevealElements.forEach((el) => {
      const splitInstance = new SplitType(el, { types: "words" });
      wordSplits.push(splitInstance);

      if (splitInstance.words?.length) {
        gsap.fromTo(
          splitInstance.words,
          { opacity: 0.18 },
          {
            opacity: 1,
            stagger: 0.025,
            ease: "none",
            scrollTrigger: {
              trigger: el,
              start: "top 85%",
              end: "bottom 50%",
              scrub: 0.5,
            },
          },
        );
      }
    });

    // ═══════════════════════════════════════════════════════
    // HERO SCROLL ZOOM, FADE & INDEPENDENT PARALLAX (Tympanus/Motion)
    // ═══════════════════════════════════════════════════════
    const heroSection = document.querySelector("section[class*='hero']");
    const heroTitle = document.querySelector("[data-hero-title]");
    const heroSubtitle = document.querySelector("[data-hero-subtitle]");
    const heroActions = document.querySelector("[data-hero-actions]");
    const duckButtons = document.querySelectorAll("button[class*='draggableDuck']");

    if (heroSection) {
      // 1. Subtitle & action buttons: fade out early before next section arrives
      const fadeItems = [heroSubtitle, heroActions].filter(Boolean) as HTMLElement[];
      if (fadeItems.length) {
        gsap.to(fadeItems, {
          opacity: 0,
          y: -28,
          ease: "power2.out",
          scrollTrigger: {
            trigger: heroSection,
            start: "top top",
            end: "45% top",
            scrub: 0.5,
          },
        });
      }

      // 2. Hero Title: subtle zoom (1 to 1.15) & graceful fade down to 0.05
      if (heroTitle) {
        gsap.to(heroTitle, {
          scale: 1.15,
          opacity: 0.05,
          y: -45,
          ease: "power1.out",
          scrollTrigger: {
            trigger: heroSection,
            start: "top top",
            end: "bottom top",
            scrub: 0.6,
          },
        });
      }

      // 3. Pingus: independent parallax drift on scroll
      const parallaxRates = [
        { y: -130, r: -5 },
        { y: -75, r: 4 },
        { y: -210, r: 8 },
        { y: -105, r: -6 },
      ];

      duckButtons.forEach((duck, i) => {
        const rate = parallaxRates[i % parallaxRates.length];
        gsap.to(duck, {
          y: rate.y,
          rotate: rate.r,
          opacity: 0.35,
          ease: "none",
          scrollTrigger: {
            trigger: heroSection,
            start: "top top",
            end: "bottom top",
            scrub: 0.5,
          },
        });
      });
    }

    // GSAP ScrollTrigger performance tuning
    ScrollTrigger.config({ limitCallbacks: true });
    gsap.ticker.lagSmoothing(500, 33);

    const cinematicBlocks = gsap.utils.toArray<HTMLElement>("[data-cinematic]");
    cinematicBlocks.forEach((block) => {
      const media = block.querySelector("img, iframe");

      gsap.fromTo(
        block,
        { "--line-scale": 0 },
        {
          "--line-scale": 1,
          duration: 0.75,
          ease: "power3.out",
          scrollTrigger: {
            trigger: block,
            start: "top 86%",
            end: "bottom 14%",
            toggleActions: "play none none reverse",
          },
        },
      );

      if (media) {
        gsap.to(media, {
          yPercent: -4,
          ease: "none",
          scrollTrigger: {
            trigger: block,
            start: "top bottom",
            end: "bottom top",
            scrub: 0.5,
          },
        });
      }
    });

    const rafId = requestAnimationFrame(() => {
      ScrollTrigger.refresh();
    });

    return () => {
      cancelAnimationFrame(rafId);
      ScrollTrigger.getAll().forEach((trigger) => trigger.kill());
      split?.revert();
      headingSplits.forEach((item) => item.revert());
      wordSplits.forEach((item) => item.revert());
    };
  }, [pathname]);

  return null;
}

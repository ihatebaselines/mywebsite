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
          clipPath: "inset(0% 100% 0% 0% round 8px)",
          scale: 1.02,
          opacity: 0.4,
        },
        {
          clipPath: "inset(0% 0% 0% 0% round 8px)",
          scale: 1,
          opacity: 1,
          duration: 0.75,
          ease: "expo.out",
          scrollTrigger: {
            trigger: item,
            start: "top 88%",
            end: "bottom 10%",
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

    // ═══════════════════════════════════════════════════════
    // HERO 3D PLUNGE TRANSITION (desktop only)
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
          end: "+=120%",
          pin: true,
          pinSpacing: false,
          scrub: 0.8,
        }
      });

      plungeTl.to(heroCopy, {
        scale: 4,
        opacity: 0,
        ease: "power2.inOut",
        duration: 0.8
      }, 0);

      duckButtons.forEach((duck, i) => {
        const xMove = i % 2 === 0 ? -180 : 180;
        const yMove = i < 2 ? -180 : 180;

        plungeTl.to(duck, {
          x: xMove,
          y: yMove,
          scale: 2.5,
          opacity: 0,
          rotate: xMove / 3,
          ease: "power2.inOut",
          duration: 0.8
        }, 0);
      });

      if (bentoCards.length) {
        plungeTl.fromTo(bentoCards, {
          scale: 0.85,
          opacity: 0,
          y: 60,
        }, {
          scale: 1,
          opacity: 1,
          y: 0,
          stagger: 0.05,
          ease: "power3.out",
          duration: 0.6
        }, 0.25);
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
  }, [pathname]);

  return null;
}

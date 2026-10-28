"use client";

import { useEffect, useState } from "react";
import Image from "next/image";

export default function RandomHeroVisual() {
  // 50% chance for glitch cat vs 50% for normal pixel cat
  const [isGlitch, setIsGlitch] = useState(false);

  useEffect(() => {
    // Determine 50/50 randomly on client mount / page join
    setIsGlitch(Math.random() < 0.5);
  }, []);

  return (
    <figure className="hero-visual">
      <Image
        src={isGlitch ? "/images/glitched_cat.jpg" : "/images/pixel-cat-hero.jpg"}
        alt={isGlitch ? "Glitched Siamese cat" : "Pixel art Siamese cat yelling against a warm orange background"}
        fill
        priority
        sizes="(max-width: 720px) 100vw, 55vw"
        style={{ objectFit: "cover" }}
      />
    </figure>
  );
}

"use client";

import Image from "next/image";
import { useHeroGlitch } from "./heroState";

export default function RandomHeroVisual() {
  const isGlitch = useHeroGlitch();

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

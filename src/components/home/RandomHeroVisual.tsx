"use client";

import Image from "next/image";

export default function RandomHeroVisual() {
  return (
    <figure className="hero-visual">
      <Image
        src="/images/pixel-cat-hero.jpg"
        alt="Pixel art Siamese cat yelling against a warm orange background"
        fill
        priority
        sizes="(max-width: 720px) 100vw, 55vw"
        style={{ objectFit: "cover" }}
      />
    </figure>
  );
}

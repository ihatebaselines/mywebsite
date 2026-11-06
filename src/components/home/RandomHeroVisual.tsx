"use client";

import Image from "next/image";

export default function RandomHeroVisual() {
  return (
    <figure className="hero-visual">
      <Image
        src="/images/pixel-cat-sunglasses.jpg"
        alt="Pixel cat wearing cool sunglasses"
        fill
        priority
        sizes="(max-width: 720px) 100vw, 45vw"
        style={{ objectFit: "cover" }}
      />
    </figure>
  );
}

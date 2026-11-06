"use client";

import Image from "next/image";
import { useState } from "react";

const CAT_IMAGES = [
  {
    src: "/images/pixel-cat-hero.jpg",
    alt: "Pixel art Siamese cat yelling against a warm orange background",
  },
  {
    src: "/images/pixel-cat-tv.jpg",
    alt: "Pixel cat watching TV with remote control",
  },
  {
    src: "/images/glitched_cat.jpg",
    alt: "Glitched Siamese cat with chromatic aberration",
  },
  {
    src: "/images/pixel-cat-sunglasses.jpg",
    alt: "Pixel cat wearing cool sunglasses",
  },
  {
    src: "/images/pixel-cat-icecream.jpg",
    alt: "Pixel cat eating ice cream",
  },
];

export default function RandomHeroVisual() {
  const [index, setIndex] = useState(0);

  const nextCat = () => {
    setIndex((prev) => (prev + 1) % CAT_IMAGES.length);
  };

  const current = CAT_IMAGES[index];

  return (
    <figure
      className="hero-visual hero-visual-interactive"
      onClick={nextCat}
      title="Click to cycle cats :)"
      role="button"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          nextCat();
        }
      }}
    >
      <Image
        src={current.src}
        alt={current.alt}
        fill
        priority
        sizes="(max-width: 720px) 100vw, 45vw"
        style={{ objectFit: "cover" }}
      />
      <span className="hero-visual-badge">cat #{index + 1}</span>
    </figure>
  );
}

"use client";

import { useEffect, useRef } from "react";

export default function DrunkTitle() {
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (videoRef.current) {
      videoRef.current.play().catch(() => {
        // Autoplay may be restricted by battery saver
      });
    }
  }, []);

  return (
    <h1 className="home-title home-title-video-wrap" id="home-title">
      <span className="sr-only">ihatebaselines.</span>
      <div className="title-video-mask" aria-hidden="true">
        <video
          ref={videoRef}
          autoPlay
          muted
          loop
          playsInline
          preload="auto"
          poster="/videos/preview.jpg"
          className="title-video-el"
        >
          <source src="/videos/hero-mask.mp4" type="video/mp4" />
          <source
            src="https://videos.pexels.com/video-files/7710243/7710243-uhd_2560_1440_30fps.mp4"
            type="video/mp4"
          />
        </video>
        <svg
          viewBox="0 0 780 102"
          preserveAspectRatio="xMinYMid meet"
          className="title-mask-svg"
        >
          <defs>
            <mask id="hero-title-mask" x="0" y="0" width="100%" height="100%">
              <rect x="0" y="0" width="100%" height="100%" fill="white" />
              <text
                x="0"
                y="80"
                fill="black"
                fontFamily="var(--font), 'JetBrains Mono', Consolas, monospace"
                fontSize="88"
                fontWeight="600"
                letterSpacing="-0.035em"
              >
                ihatebaselines.
              </text>
            </mask>
          </defs>
          <rect
            x="0"
            y="0"
            width="100%"
            height="100%"
            className="title-mask-cover"
            style={{ fill: "var(--bg)" }}
            mask="url(#hero-title-mask)"
          />
        </svg>
      </div>
    </h1>
  );
}

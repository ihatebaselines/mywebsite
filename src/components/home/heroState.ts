"use client";

import { useEffect, useState } from "react";

// Synchronized state across HeroTitle and RandomHeroVisual on the homepage
let globalHeroGlitch: boolean | null = null;
const heroListeners = new Set<(val: boolean) => void>();

export function useHeroGlitch(): boolean {
  const [isGlitch, setIsGlitch] = useState<boolean>(() => {
    return globalHeroGlitch ?? false;
  });

  useEffect(() => {
    if (globalHeroGlitch === null) {
      // 50/50 chance on home page load
      globalHeroGlitch = Math.random() < 0.5;
    }
    setIsGlitch(globalHeroGlitch);
    heroListeners.add(setIsGlitch);
    return () => {
      heroListeners.delete(setIsGlitch);
    };
  }, []);

  return isGlitch;
}

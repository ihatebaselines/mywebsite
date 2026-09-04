"use client";

export interface Achievement {
  id: number;
  label: string;
  description: string;
}

export const ACHIEVEMENTS: Achievement[] = [
  { id: 0, label: "[0] found nothing", description: "Encountered the void." },
  { id: 1, label: "[1] found something", description: "Discovered One Mode." },
  { id: 2, label: "[2] broke a baseline", description: "Baselines are made to be broken." },
  { id: 3, label: "[3] annoyed a pingu", description: "Persistent interaction with penguins." },
  { id: 4, label: "[4] read the source", description: "Inspected the licenses or console." },
  { id: 5, label: "[5] reached the end", description: "Patiently waited at the footer." },
];

const STORAGE_KEY = "ihateb_achievements";

export function getUnlockedAchievements(): number[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

export function unlockAchievement(id: number) {
  if (typeof window === "undefined") return;

  const current = getUnlockedAchievements();
  if (current.includes(id)) return;

  const updated = [...current, id];
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
  } catch {
    // ignore
  }

  const item = ACHIEVEMENTS.find((a) => a.id === id);
  if (item) {
    window.dispatchEvent(
      new CustomEvent("achievement-unlocked", { detail: { achievement: item } })
    );
  }

  if (updated.length === ACHIEVEMENTS.length) {
    window.dispatchEvent(new CustomEvent("all-achievements-unlocked"));
  }
}

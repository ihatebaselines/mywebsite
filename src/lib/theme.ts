"use client";

export type SiteMode = "zero" | "one";

export const THEME_STORAGE_KEY = "ihateb_mode";

export function getInitialTheme(): SiteMode {
  if (typeof window === "undefined") return "zero";
  try {
    const saved = localStorage.getItem(THEME_STORAGE_KEY);
    if (saved === "one" || saved === "zero") return saved;
  } catch {
    // fallback
  }
  return "zero";
}

export function setSiteTheme(mode: SiteMode, showTransition = true) {
  if (typeof window === "undefined") return;

  try {
    localStorage.setItem(THEME_STORAGE_KEY, mode);
  } catch {
    // ignore
  }

  document.documentElement.setAttribute("data-theme", mode);

  if (showTransition) {
    window.dispatchEvent(
      new CustomEvent("trigger-mode-transition", { detail: { mode } })
    );
  }

  window.dispatchEvent(new CustomEvent("theme-change", { detail: { mode } }));
}

export function toggleSiteTheme() {
  const current =
    document.documentElement.getAttribute("data-theme") === "one"
      ? "one"
      : "zero";
  const next = current === "zero" ? "one" : "zero";
  setSiteTheme(next, true);
  return next;
}

"use client";

import { useEffect, useState } from "react";

export default function ThemeToggle() {
  const [theme, setTheme] = useState<"default" | "glitch">("default");

  useEffect(() => {
    const saved = localStorage.getItem("ihb-theme") as "default" | "glitch" | null;
    if (saved) {
      setTheme(saved);
      document.documentElement.setAttribute("data-theme", saved);
    }
  }, []);

  const toggle = () => {
    const next = theme === "default" ? "glitch" : "default";
    setTheme(next);
    localStorage.setItem("ihb-theme", next);
    document.documentElement.setAttribute("data-theme", next);
  };

  return (
    <button
      type="button"
      onClick={toggle}
      title={`Toggle theme (current: ${theme})`}
      style={{
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        width: "36px",
        height: "36px",
        padding: "0",
        border: "1px solid var(--border)",
        borderRadius: "var(--radius)",
        background: "var(--surface)",
        cursor: "pointer",
        transition: "border-color 150ms ease, background 150ms ease",
      }}
      aria-label="Toggle glitch theme"
    >
      <span
        style={{
          display: "inline-block",
          width: "14px",
          height: "14px",
          borderRadius: "50%",
          background:
            theme === "glitch"
              ? "linear-gradient(135deg, #00d2d3, #d926a9)"
              : "var(--accent)",
          boxShadow: theme === "glitch" ? "0 0 6px rgba(217, 38, 169, 0.6)" : "none",
          transition: "background 150ms ease, transform 150ms ease",
        }}
      />
    </button>
  );
}

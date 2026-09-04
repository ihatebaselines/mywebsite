"use client";

interface LeaderboardBadgeProps {
  rank: string;
  points: string;
}

export default function LeaderboardBadge({ rank, points }: LeaderboardBadgeProps) {
  return (
    <div
      style={{
        padding: "0.75rem 1.1rem",
        border: "1px solid var(--border)",
        borderRadius: "4px",
        display: "inline-block",
        background: "rgba(245, 240, 235, 0.03)",
        cursor: "default",
      }}
    >
      <div
        style={{
          fontSize: "0.75rem",
          textTransform: "uppercase",
          letterSpacing: "0.06em",
          opacity: 0.6,
          marginBottom: "0.25rem",
          fontFamily: "var(--font-jetbrains-mono, monospace)",
        }}
      >
        <span>mlcompete</span>
      </div>

      <p
        style={{
          margin: 0,
          fontSize: "1.05rem",
          fontWeight: 600,
          fontFamily: "var(--font-jetbrains-mono, monospace)",
          whiteSpace: "nowrap",
        }}
      >
        rank #{rank}{" "}
        <span style={{ fontSize: "0.85rem", opacity: 0.7, fontWeight: 400 }}>
          ({points} pts)
        </span>
      </p>
    </div>
  );
}

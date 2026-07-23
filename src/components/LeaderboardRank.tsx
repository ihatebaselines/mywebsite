import React from "react";

async function fetchRank() {
  try {
    const res = await fetch("https://platform.olimpiada-ai.ro/ro/leaderboard", {
      next: { revalidate: 3600 },
    });
    if (!res.ok) return null;
    const html = await res.text();
    // Example format in JSON-LD: "name":"ihatebaselines","url":"...","description":"Rank #5 with 7767.35 points"
    const match = html.match(/"name":"ihatebaselines".*?"description":"Rank #(\d+)\s+with\s+([\d.]+)\s+points"/);
    if (match) {
      return {
        rank: match[1],
        points: match[2],
      };
    }
  } catch (e) {
    console.error("Failed to fetch MLCompete rank:", e);
  }
  return null;
}

export default async function LeaderboardRank() {
  const data = await fetchRank();

  if (!data) return null;

  return (
    <div
      style={{
        marginTop: "1.5rem",
        padding: "1rem",
        border: "1px solid rgba(255, 255, 255, 0.1)",
        borderRadius: "8px",
        display: "inline-block",
        background: "rgba(0, 0, 0, 0.2)",
      }}
    >
      <div style={{ fontSize: "0.75rem", textTransform: "uppercase", letterSpacing: "0.05em", opacity: 0.6, marginBottom: "0.25rem" }}>
        mlcompete
      </div>
      <p style={{ margin: 0, fontSize: "1.1rem", fontWeight: 600 }}>
        rank #{data.rank}{" "}
        <span style={{ fontSize: "0.9rem", opacity: 0.7, fontWeight: 400 }}>
          ({data.points} pts)
        </span>
      </p>
    </div>
  );
}

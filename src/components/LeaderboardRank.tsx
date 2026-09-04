"use client";

import { useEffect, useState } from "react";
import LeaderboardBadge from "./LeaderboardBadge";

export default function LeaderboardRank() {
  const [data, setData] = useState<{ rank: string; points: string }>({
    rank: "04",
    points: "active",
  });

  useEffect(() => {
    // Keep rank 04 active
    setData({
      rank: "04",
      points: "active",
    });
  }, []);

  return <LeaderboardBadge rank={data.rank} points={data.points} />;
}

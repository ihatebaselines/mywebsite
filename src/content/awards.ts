export type AwardItem = {
  id: string;
  title: string;
  event: string;
  category: string;
  date: string;
  place: string;
  tier: "gold" | "silver" | "bronze" | "special";
  badge: string;
  score?: string;
  division?: string;
  description: string;
  links?: { label: string; url: string }[];
  tags: string[];
};

import awardsData from "./awardsData.json";

export const awards: AwardItem[] = awardsData as AwardItem[];

export function getAwards() {
  return awards;
}

export function getAwardsStats() {
  return {
    total: awards.length,
    podiums: awards.filter((a) => a.tier === "gold" || a.tier === "silver" || a.tier === "bronze").length,
    firstPlaces: awards.filter((a) => a.tier === "gold").length,
    prizeMoney: "€1,000",
    hackathons: "48h+",
  };
}

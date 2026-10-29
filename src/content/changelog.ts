export type ChangelogEntry = {
  version: string;
  codename?: string;
  image?: string;
  imageGlitch?: string;
  date: string;
  title: string;
  tag: string;
  tagType: "competition" | "feature" | "milestone" | "system";
  summary: string;
  changes: string[];
  quote?: string;
  quoteAuthor?: string;
  quoteSource?: string;
};

import changelogData from "./changelogData.json";

export const changelog: ChangelogEntry[] = changelogData as ChangelogEntry[];

export function getChangelog() {
  return changelog;
}

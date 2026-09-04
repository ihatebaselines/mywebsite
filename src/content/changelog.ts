export type ChangelogEntry = {
  version: string;
  date: string;
  title: string;
  tag: string;
  tagType: "competition" | "feature" | "milestone" | "system";
  summary: string;
  changes: string[];
  quote?: string;
};

import changelogData from "./changelogData.json";

export const changelog: ChangelogEntry[] = changelogData as ChangelogEntry[];

export function getChangelog() {
  return changelog;
}

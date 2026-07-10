export type OpenSourceItem = {
  slug: string;
  name: string;
  description: string;
  repoUrl: string;
  language: string;
  topics: string[];
  image?: string;
};

import opensourceData from "./opensourceData.json";

export const opensourceItems: OpenSourceItem[] =
  opensourceData as OpenSourceItem[];

export function getOpenSourceItem(slug: string) {
  return opensourceItems.find((item) => item.slug === slug);
}

export function getSortedOpenSource() {
  return [...opensourceItems];
}

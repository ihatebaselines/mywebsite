export type WorkItem = {
  slug: string;
  title: string;
  date: string;
  tag: string;
  summary: string;
  image: string;
  gallery?: string[];
  body: string[];
  relatedHref?: string;
  embedUrl?: string;
  repoUrl?: string;
};

import workData from "./workData.json";

// Edit this list whenever you want the "Last work" section to change.
// Put Kaggle notebooks/datasets in embedUrl when you want the live preview box.
export const workItems: WorkItem[] = workData as WorkItem[];

export function getWork(slug: string) {
  return workItems.find((item) => item.slug === slug);
}

export function getSortedWork() {
  return [...workItems].sort(
    (first, second) =>
      new Date(second.date).getTime() - new Date(first.date).getTime(),
  );
}

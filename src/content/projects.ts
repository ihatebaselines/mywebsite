export type ProjectItem = {
  slug: string;
  title: string;
  description: string;
  tags: string[];
  image: string;
  repoUrl?: string;
  liveUrl?: string;
  date: string;
  featured: boolean;
};

import projectsData from "./projectsData.json";

export const projects: ProjectItem[] = projectsData as ProjectItem[];

export function getProject(slug: string) {
  return projects.find((project) => project.slug === slug);
}

export function getSortedProjects() {
  return [...projects].sort(
    (first, second) =>
      new Date(second.date).getTime() - new Date(first.date).getTime(),
  );
}

export function getFeaturedProjects() {
  return getSortedProjects().filter((project) => project.featured);
}

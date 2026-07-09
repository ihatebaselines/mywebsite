export type BlogPost = {
  slug: string;
  title: string;
  date: string;
  category: string;
  excerpt: string;
  shortStory: string;
  cover: string;
  gallery: string[];
  body: string[];
};

import postsData from "./postsData.json";

export const posts: BlogPost[] = postsData as BlogPost[];

export function getPost(slug: string) {
  return posts.find((post) => post.slug === slug);
}

export function getSortedPosts() {
  return [...posts].sort(
    (first, second) =>
      new Date(second.date).getTime() - new Date(first.date).getTime(),
  );
}

"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import type { BlogPost } from "@/content/posts";
import styles from "@/app/page.module.css";

export default function BlogSearch({ posts }: { posts: BlogPost[] }) {
  const [query, setQuery] = useState("");

  const filteredPosts = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();

    if (!normalizedQuery) {
      return posts;
    }

    return posts.filter((post) =>
      [
        post.title,
        post.date,
        post.category,
        post.excerpt,
        post.shortStory,
        post.body.join(" "),
      ]
        .join(" ")
        .toLowerCase()
        .includes(normalizedQuery),
    );
  }, [posts, query]);

  return (
    <div className={styles.blogSearch}>
      <label className={styles.searchBox}>
        <span>Search posts</span>
        <input
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search by title, date, category..."
          type="search"
        />
      </label>

      <div className={styles.searchMeta}>
        {filteredPosts.length} / {posts.length} posts
      </div>

      <div className={styles.postGrid}>
        {filteredPosts.map((post, index) => (
          <Link
            className={styles.postCard}
            href={`/blog/${post.slug}`}
            key={`${post.slug}-${post.date}-${index}`}
          >
            <div className={styles.postImage}>
              <img src={post.cover} alt="" />
            </div>
            <div>
              <p>
                {post.category} / {post.date}
              </p>
              <h3>{post.title}</h3>
              <span>{post.excerpt}</span>
            </div>
          </Link>
        ))}
      </div>

      {filteredPosts.length === 0 ? (
        <p className={styles.emptySearch}>No posts found for that search.</p>
      ) : null}
    </div>
  );
}

"use client";

import { useMemo, useState, useEffect } from "react";
import Link from "next/link";
import type { BlogPost } from "@/content/posts";
import { setSiteTheme } from "@/lib/theme";
import { unlockAchievement } from "@/lib/progression";
import styles from "@/app/page.module.css";

export default function BlogSearch({ posts }: { posts: BlogPost[] }) {
  const [query, setQuery] = useState("");
  const [slowScrollUnlocked, setSlowScrollUnlocked] = useState(false);

  // Slow-scroll detector: slowly scrolling through the blog reveals the hidden post
  useEffect(() => {
    let lastScrollY = window.scrollY;
    let lastTime = performance.now();
    let slowCount = 0;

    const handleScroll = () => {
      const now = performance.now();
      const dt = now - lastTime;
      if (dt < 25) return;
      const dy = Math.abs(window.scrollY - lastScrollY);
      const speed = dy / dt; // px per ms

      if (speed > 0.03 && speed < 0.45) {
        slowCount++;
        if (slowCount >= 7) {
          setSlowScrollUnlocked(true);
        }
      } else if (speed > 1.5) {
        slowCount = 0;
      }
      lastScrollY = window.scrollY;
      lastTime = now;
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const filteredPosts = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();

    if (!normalizedQuery) {
      return posts;
    }

    // Fake query easter eggs
    if (normalizedQuery === "nothing") {
      return [
        {
          slug: "nothing",
          title: "Nothing — 0 min read",
          date: "0000-00-00",
          category: "VOID",
          excerpt: "room for everything.",
          shortStory: "0 was the origin.",
          body: ["nothing is not the absence of something. it's room for it."],
          cover: "/images/pingu-standing.png",
          readingTime: "0 min",
          tags: ["void", "zero"],
        } as BlogPost,
      ];
    }

    if (normalizedQuery === "1") {
      return [
        {
          slug: "a-new-beginning",
          title: "A New Beginning — 1 min read",
          date: "2026-09-04",
          category: "ONE",
          excerpt: "1 means begin again. Discovered One Mode.",
          shortStory: "you moved. baseline left behind.",
          body: ["something was found."],
          cover: "/images/pingu-waving.png",
          readingTime: "1 min",
          tags: ["one", "mode"],
        } as BlogPost,
      ];
    }

    if (normalizedQuery === "penguin") {
      return [
        {
          slug: "classified",
          title: "classified.",
          date: "top secret",
          category: "NOOT",
          excerpt: "top secret noot operations. eyes only.",
          shortStory: "classified pingu archives.",
          body: ["noot noot."],
          cover: "/images/pingu-chair.png",
          readingTime: "∞",
          tags: ["pingu", "classified"],
        } as BlogPost,
      ];
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

  const handleFakePostClick = (slug: string) => {
    if (slug === "nothing") {
      unlockAchievement(0);
    } else if (slug === "a-new-beginning") {
      setSiteTheme("one", true);
      unlockAchievement(1);
    } else if (slug === "classified") {
      unlockAchievement(3);
    }
  };

  return (
    <div className={styles.blogSearch}>
      <label className={styles.searchBox}>
        <span>Search posts</span>
        <input
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search by title, date, category... (try 1, nothing, or penguin)"
          type="search"
        />
      </label>

      <div className={styles.searchMeta}>
        {filteredPosts.length} / {posts.length} posts
      </div>

      <div className={styles.postGrid}>
        {filteredPosts.map((post, index) => {
          const isFake =
            post.slug === "nothing" ||
            post.slug === "a-new-beginning" ||
            post.slug === "classified";

          if (isFake) {
            return (
              <div
                className={styles.postCard}
                key={post.slug}
                onClick={() => handleFakePostClick(post.slug)}
                style={{ cursor: "pointer" }}
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
              </div>
            );
          }

          return (
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
          );
        })}

        {/* Slow-scroll invisible post easter egg */}
        {slowScrollUnlocked && !query && (
          <div
            className={styles.postCard}
            style={{
              borderStyle: "dashed",
              borderColor: "rgba(255, 255, 255, 0.28)",
              background: "rgba(20, 18, 18, 0.8)",
            }}
          >
            <div className={styles.postImage} style={{ background: "#111" }}>
              <img src="/images/pingu.png" alt="" />
            </div>
            <div>
              <p>SECRET / ∞ MIN READ</p>
              <h3>you weren&apos;t supposed to find this.</h3>
              <span>
                detected extremely patient scroll velocity. congratulations.
              </span>
            </div>
          </div>
        )}
      </div>

      {filteredPosts.length === 0 ? (
        <p className={styles.emptySearch}>0 posts found. suspiciously peaceful.</p>
      ) : null}
    </div>
  );
}

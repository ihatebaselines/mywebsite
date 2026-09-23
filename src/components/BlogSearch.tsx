"use client";

import Image from "next/image";
import Link from "next/link";
import { useMemo, useState } from "react";
import type { BlogPost } from "@/content/posts";

export default function BlogSearch({ posts }: { posts: BlogPost[] }) {
  const [query, setQuery] = useState("");
  const matches = useMemo(() => {
    const term = query.trim().toLowerCase();
    if (!term) return posts;
    return posts.filter((post) => `${post.title} ${post.date} ${post.category} ${post.excerpt} ${post.shortStory}`.toLowerCase().includes(term));
  }, [posts, query]);

  return (
    <div>
      <div className="search-controls">
        <label className="search-field-wrap" style={{ flex: 1 }}>
          <span className="visually-hidden">Search posts</span>
          <input className="search-field" type="search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search posts by title, date, or topic…" />
        </label>
        <span className="search-count">{matches.length} / {posts.length} posts</span>
      </div>
      {matches.length ? <div className="listing-grid">
        {matches.map((post) => <article className="entry-card" key={post.slug}>
          <Link className="entry-card-link" href={`/blog/${post.slug}`}>
            <div className="entry-image"><Image src={post.cover} alt="" fill sizes="(max-width: 720px) 90vw, 45vw" /></div>
            <div className="entry-copy"><p className="entry-meta">{post.category} · {post.date}</p><h2>{post.title}</h2><p>{post.excerpt}</p><span className="entry-arrow" aria-hidden="true">→</span></div>
          </Link>
        </article>)}
      </div> : <p className="empty-state">No posts match “{query}”. Try another search.</p>}
    </div>
  );
}

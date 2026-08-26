import React from "react";
import { notFound } from "next/navigation";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import PhotoGallery from "@/components/PhotoGallery";
import { getPost, posts } from "@/content/posts";
import styles from "@/app/page.module.css";

export function generateStaticParams() {
  return posts.map((post) => ({ slug: post.slug }));
}

function renderFormattedParagraph(text: string) {
  const linkRegex = /\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/g;
  const elements: React.ReactNode[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  while ((match = linkRegex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      elements.push(text.substring(lastIndex, match.index));
    }
    const label = match[1];
    const url = match[2];
    const isTag = label.startsWith("#");
    elements.push(
      <a
        key={`${match.index}-${url}`}
        href={url}
        target="_blank"
        rel="noreferrer"
        className={isTag ? styles.articleTagLink : styles.articleInlineLink}
      >
        {label}
      </a>
    );
    lastIndex = linkRegex.lastIndex;
  }

  if (lastIndex < text.length) {
    elements.push(text.substring(lastIndex));
  }

  return elements.length > 0 ? elements : text;
}

export default async function BlogPostPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const post = getPost(slug);

  if (!post) {
    notFound();
  }

  return (
    <main className={styles.page}>
      <Navbar backHref="/#blog" backLabel="Back" />

      <article className={styles.article}>
        <header className={styles.articleHeader}>
          <p>{post.category} / {post.date}</p>
          <h1>{post.title}</h1>
          <span>{post.excerpt}</span>
        </header>

        <div className={styles.articleCover}>
          <img
            className={styles.articleCoverGlow}
            src={post.cover}
            alt=""
            loading="eager"
            decoding="async"
          />
          <img
            className={styles.articleCoverImage}
            src={post.cover}
            alt=""
            loading="eager"
            decoding="async"
          />
        </div>

        <div className={styles.articleBody}>
          {post.body.map((paragraph, idx) => (
            <p key={idx}>{renderFormattedParagraph(paragraph)}</p>
          ))}
        </div>

        {post.links && post.links.length > 0 ? (
          <div className={styles.resourceSection}>
            <div className={styles.sectionHeader}>
              <p>Resources & Problem Sets</p>
              <h2 className={styles.resourceSectionTitle}>Official Competition Links</h2>
            </div>
            <div className={styles.resourceGrid}>
              {post.links.map((link, idx) => (
                <a
                  key={idx}
                  href={link.url}
                  target="_blank"
                  rel="noreferrer"
                  className={styles.resourceCard}
                >
                  <div className={styles.resourceTop}>
                    <span className={link.url.includes("olimpiada-ai") ? styles.resourceBadgeAI : styles.resourceBadge}>
                      {link.badge || (link.url.includes("olimpiada-ai") ? "Competition Tasks" : "Official Event")}
                    </span>
                    <svg
                      className={styles.resourceArrow}
                      width="18"
                      height="18"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <line x1="7" y1="17" x2="17" y2="7" />
                      <polyline points="7 7 17 7 17 17" />
                    </svg>
                  </div>
                  <h3>{link.title}</h3>
                  {link.description ? <p>{link.description}</p> : null}
                  <span className={styles.resourceUrl}>
                    {link.url.replace(/^https?:\/\//, "").replace(/\/$/, "")}
                  </span>
                </a>
              ))}
            </div>
          </div>
        ) : null}

        {post.gallery && post.gallery.length > 0 ? (
          <PhotoGallery images={post.gallery} title="Event Photos & Showcase" />
        ) : null}
      </article>
    </main>
  );
}


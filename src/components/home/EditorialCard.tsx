"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import styles from "@/app/page.module.css";

export interface CompetitionCardProps {
  number: string; // "01", "02", etc.
  category: string;
  date: string;
  title: string;
  description: string;
  slug: string;
  isWide?: boolean;
  extraMeta?: string; // e.g. "loss: 0.042 · Ego: NaN"
}

export function CompetitionCard({
  number,
  category,
  date,
  title,
  description,
  slug,
  isWide = false,
  extraMeta,
}: CompetitionCardProps) {
  return (
    <article
      className={`${styles.editorialCompetitionCard} ${
        isWide ? styles.editorialCardWide : ""
      }`}
    >
      <div className={styles.editorialCardTop}>
        <div className={styles.editorialCardNum}>{number}</div>
        <div className={styles.editorialCardMeta}>
          {category} / {date}
        </div>
        {extraMeta && (
          <div className={styles.editorialCardExtraMeta}>{extraMeta}</div>
        )}
        <h3 className={styles.editorialCardTitle}>{title}</h3>
        <p className={styles.editorialCardDesc}>{description}</p>
      </div>

      <div className={styles.editorialCardBottom}>
        <Link
          href={`/blog/${slug}`}
          className={styles.editorialCardActionBtn}
        >
          VISIT BLOG →
        </Link>
      </div>
    </article>
  );
}

export interface BlogArticleCardProps {
  slug: string;
  title: string;
  date: string;
  category: string;
  excerpt: string;
  image: string;
  variant?: "featured" | "compact" | "stacked";
}

export function BlogArticleCard({
  slug,
  title,
  date,
  category,
  excerpt,
  image,
  variant = "stacked",
}: BlogArticleCardProps) {
  const [loaded, setLoaded] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    if (imgRef.current && imgRef.current.complete) {
      setLoaded(true);
    }
  }, []);

  return (
    <Link
      href={`/blog/${slug}`}
      className={`${styles.blogArticleCardRoot} ${
        variant === "featured"
          ? styles.blogArticleFeatured
          : variant === "compact"
          ? styles.blogArticleCompact
          : styles.blogArticleStacked
      }`}
    >
      <div className={styles.blogArticleMedia} style={{ position: "relative" }}>
        {!loaded && (
          <div className={styles.cardImageSkeleton} aria-hidden="true" />
        )}
        <img
          ref={imgRef}
          src={image}
          alt={title}
          className={styles.blogArticleImg}
          loading="eager"
          decoding="async"
          onLoad={() => setLoaded(true)}
          onError={() => setLoaded(true)}
        />
      </div>

      <div className={styles.blogArticleContent}>
        <div className={styles.blogArticleMeta}>
          {category} / {date}
        </div>
        <h3 className={styles.blogArticleTitle}>{title}</h3>
        <p className={styles.blogArticleExcerpt}>{excerpt}</p>
        <span className={styles.blogArticleReadMore}>READ MORE →</span>
      </div>
    </Link>
  );
}

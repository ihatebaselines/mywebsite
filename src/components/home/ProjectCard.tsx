"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import styles from "@/app/page.module.css";

export interface ProjectCardProps {
  slug: string;
  title: string;
  date: string;
  category: string;
  description: string;
  image: string;
  href?: string;
}

export default function ProjectCard({
  slug,
  title,
  date,
  category,
  description,
  image,
  href,
}: ProjectCardProps) {
  const [loaded, setLoaded] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);
  const targetHref = href || `/work/${slug}`;

  useEffect(() => {
    if (imgRef.current && imgRef.current.complete) {
      setLoaded(true);
    }
  }, []);

  return (
    <Link href={targetHref} className={styles.projectCardEditorial}>
      <div className={styles.projectCardMediaArea}>
        {!loaded && (
          <div className={styles.cardImageSkeleton} aria-hidden="true" />
        )}
        <img
          ref={imgRef}
          src={image}
          alt={title}
          className={styles.projectCardImg}
          loading="eager"
          decoding="async"
          onLoad={() => setLoaded(true)}
          onError={() => setLoaded(true)}
        />
      </div>

      <div className={styles.projectCardMetaRow}>
        <span>{category}</span>
        <span className={styles.projectCardMetaDot}>/</span>
        <span>{date}</span>
      </div>

      <h3 className={styles.projectCardHeading}>{title}</h3>

      <p className={styles.projectCardParagraph}>{description}</p>

      <div className={styles.projectCardFooter}>
        <span className={styles.projectCardArrow} aria-hidden="true">
          →
        </span>
      </div>
    </Link>
  );
}

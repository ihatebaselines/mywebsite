"use client";

import { useState } from "react";
import Link from "next/link";
import { motion } from "motion/react";
import Tilt from "react-parallax-tilt";
import type { WorkItem } from "@/content/work";
import styles from "@/app/page.module.css";

export default function RecentWork({
  items,
  showAll = false,
}: {
  items: WorkItem[];
  showAll?: boolean;
}) {
  const [active, setActive] = useState<string | null>(null);
  const [pointer, setPointer] = useState({ x: 50, y: 50 });

  return (
    <motion.div
      className={styles.workGrid}
      initial={{ opacity: 0, y: 18 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
    >
      {items.map((item) => {
        const content = (
          <>
            <div
              className={styles.workImage}
              data-clip-reveal
              data-cinematic
            >
              <img src={item.image} alt="" loading="lazy" decoding="async" />
            </div>
            <div className={styles.workText}>
              <p>
                {item.tag} / {item.date}
              </p>
              <h3>{item.title}</h3>
              <span>{item.summary}</span>
            </div>
            {item.embedUrl ? (
              <div className={styles.embedPreview}>
                <iframe
                  src={item.embedUrl}
                  title={`${item.title} live embed`}
                  loading="lazy"
                />
              </div>
            ) : null}
            {item.repoUrl ? (
              <div className={styles.repoPreview}>
                <p>GitHub repo</p>
                <strong>{item.repoUrl.replace("https://github.com/", "")}</strong>
                <span>Open source build / code preview</span>
              </div>
            ) : null}
          </>
        );

        return (
          <motion.div
            className={styles.workGridItem}
            key={`${item.slug}-${item.date}`}
            initial={{ opacity: 0, y: 22 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.45, delay: 0.04, ease: [0.22, 1, 0.36, 1] }}
          >
            <Tilt
              tiltMaxAngleX={4}
              tiltMaxAngleY={6}
              glareEnable
              glareMaxOpacity={0.16}
              glareColor="#ffffff"
              glarePosition="all"
              scale={1.015}
              transitionSpeed={1200}
            >
            <Link
              className={`${styles.workCard} ${
                active === item.slug ? styles.workCardActive : ""
              }`}
              data-card
              href={`/work/${item.slug}`}
                style={
                  {
                    "--mx": `${pointer.x}%`,
                    "--my": `${pointer.y}%`,
                    "--mxn": pointer.x,
                    "--myn": pointer.y,
                  } as React.CSSProperties
                }
                onMouseEnter={() => setActive(item.slug)}
                onMouseLeave={() => setActive(null)}
                onMouseMove={(event) => {
                  const rect = event.currentTarget.getBoundingClientRect();
                  setPointer({
                    x: ((event.clientX - rect.left) / rect.width) * 100,
                    y: ((event.clientY - rect.top) / rect.height) * 100,
                  });
                }}
              >
                {content}
              </Link>
            </Tilt>
          </motion.div>
        );
      })}
    </motion.div>
  );
}

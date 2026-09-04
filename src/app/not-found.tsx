"use client";

import Link from "next/link";
import styles from "./not-found.module.css";

export default function NotFound() {
  return (
    <div className={styles.container}>
      <section className={styles.v3Stage} aria-label="404 Typographic">
        <div className={styles.v3Grid}>
          <div className={styles.v3TypoCol}>
            <h1 className={styles.v3BigText}>
              SOME
              <br />
              THINGS
              <br />
              JUST <span className={styles.v3Italic}>DON&apos;T</span>
              <br />
              EXIST.
            </h1>
          </div>

          <div className={styles.v3RightCol}>
            <p className={styles.v3RightSub}>and that&apos;s okay.</p>
            <p className={styles.v3RightText}>
              not everything
              <br />
              needs to exist
              <br />
              to be meaningful.
            </p>
            <Link href="/" className={styles.whiteBtn}>
              Back home →
            </Link>
          </div>
        </div>
      </section>

      <footer className={styles.footerBar}>
        <div className={styles.footerLeft}>
          nothing is not the absence of something. it&apos;s room for it.
        </div>
        <div className={styles.footerRight}>— 0</div>
      </footer>
    </div>
  );
}

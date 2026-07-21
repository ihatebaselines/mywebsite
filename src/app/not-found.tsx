"use client";

import Link from "next/link";
import Navbar from "@/components/Navbar";
import styles from "@/app/page.module.css";

export default function NotFound() {
  return (
    <main className={styles.page}>
      <Navbar backHref="/" backLabel="Home" />
      
      <section className={styles.pageHero} style={{ minHeight: "80vh", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div className={styles.pageHeroGlow} aria-hidden="true" />
        <div className={styles.loadingContent} style={{ zIndex: 10, flexDirection: "column", textAlign: "center", gap: "12px" }}>
          <div className={styles.loadingPinguWrap}>
            <img
              src="/images/pingu-sad.png"
              alt="404 Pingu"
              className={styles.loadingPingu}
              style={{ animation: "none", width: "200px" }}
            />
          </div>
          <h1 className={styles.loadingNoot} style={{ margin: "20px 0 10px" }}>404 - noot noot!</h1>
          <p style={{ color: "rgba(255, 255, 255, 0.6)", fontSize: "16px", marginBottom: "30px", maxWidth: "400px" }}>
            The page you are looking for does not exist or has been moved to another baseline.
          </p>
          <Link href="/" className={styles.rawButton}>
            <span>Back to safety 🐧</span>
          </Link>
        </div>
      </section>
    </main>
  );
}

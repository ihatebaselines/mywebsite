"use client";

import { useEffect } from "react";
import Navbar from "@/components/Navbar";
import styles from "@/app/page.module.css";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <main className={styles.page}>
      <Navbar backHref="/" backLabel="Home" />

      <section className={styles.pageHero} style={{ minHeight: "80vh", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div className={styles.pageHeroGlow} aria-hidden="true" />
        <div className={styles.loadingContent} style={{ zIndex: 10, flexDirection: "column", textAlign: "center", gap: "12px" }}>
          <div className={styles.loadingPinguWrap}>
            <img
              src="/images/pingu-sad.png"
              alt="Error Pingu"
              className={styles.loadingPingu}
              style={{ animation: "none", width: "200px" }}
            />
          </div>
          <h1 className={styles.loadingNoot} style={{ margin: "20px 0 10px" }}>something broke!</h1>
          <p style={{ color: "rgba(255, 255, 255, 0.6)", fontSize: "16px", marginBottom: "30px", maxWidth: "400px" }}>
            A baseline went out of bounds. Please try again.
          </p>
          <div style={{ display: "flex", gap: "12px", justifyContent: "center" }}>
            <button className={styles.rawButton} onClick={reset} data-no-cat-drag>
              <span>Try again 🔄</span>
            </button>
            <a href="/" className={styles.projectButton} style={{ display: "inline-flex", alignItems: "center" }}>
              Go home
            </a>
          </div>
        </div>
      </section>
    </main>
  );
}

"use client";

import { useEffect, useState } from "react";
import styles from "./LoadingScreen.module.css";

export default function LoadingScreen() {
  const [visible, setVisible] = useState(true);
  const [hiding, setHiding] = useState(false);
  const [showZero, setShowZero] = useState(false);

  useEffect(() => {
    try {
      const alreadyLoaded = sessionStorage.getItem("ihateb_opened");
      if (alreadyLoaded) {
        setVisible(false);
        return;
      }
      sessionStorage.setItem("ihateb_opened", "true");
    } catch {
      // ignore storage restrictions
    }

    // Phase 1 (0ms - 550ms): "ihatebaselines"
    // Phase 2 (550ms): "0" appears underneath (where "...yet." was)
    const zeroTimer = setTimeout(() => {
      setShowZero(true);
    }, 550);

    // Fade out at 1400ms
    const hideTimer = setTimeout(() => {
      setHiding(true);
      setTimeout(() => setVisible(false), 450);
    }, 1400);

    return () => {
      clearTimeout(zeroTimer);
      clearTimeout(hideTimer);
    };
  }, []);

  if (!visible) return null;

  return (
    <div
      className={`${styles.loadingScreen} ${hiding ? styles.loadingScreenHide : ""}`}
      aria-hidden="true"
    >
      <div className={styles.loadingCenter}>
        <div className={styles.loadingTextMain}>ihatebaselines</div>
        {showZero && <div className={styles.loadingTextSub}>0</div>}
      </div>
    </div>
  );
}

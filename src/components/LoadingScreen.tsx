"use client";

import { useEffect, useState } from "react";
import styles from "@/app/page.module.css";

const NOOT_MESSAGES = [
  "hi bro",
  "lowk loading the website",
  "kinda lit innit",
  "just sayin",
  "its finna be lit",
  "dw",
  "aint bad innit",
  "noot noot",
  "whatever",

];

export default function LoadingScreen() {
  const [visible, setVisible] = useState(true);
  const [hiding, setHiding] = useState(false);
  const [msgIndex, setMsgIndex] = useState(0);

  useEffect(() => {
    // Cycle through noot messages
    const msgInterval = setInterval(() => {
      setMsgIndex((i) => (i + 1) % NOOT_MESSAGES.length);
    }, 400);

    // Start hiding after 1.8s
    const hideTimer = setTimeout(() => {
      clearInterval(msgInterval);
      setHiding(true);
      // Fully remove after fade animation
      setTimeout(() => setVisible(false), 200);
    }, 200);

    return () => {
      clearInterval(msgInterval);
      clearTimeout(hideTimer);
    };
  }, []);

  if (!visible) return null;

  return (
    <div
      className={`${styles.loadingScreen} ${hiding ? styles.loadingScreenHide : ""}`}
      aria-hidden="true"
    >
      <div className={styles.loadingContent}>
        <div className={styles.loadingRow}>
          <img
            src="/images/pingu-waving.png"
            alt="Pingu"
            className={`${styles.loadingPingu} ${hiding ? styles.loadingPinguOut : ""}`}
          />
          <div className={styles.loadingTextCol}>
            <span className={styles.loadingBrand}>ihatebaselines</span>
            <p className={styles.loadingNoot}>{NOOT_MESSAGES[msgIndex]}</p>
          </div>
        </div>
      </div>
    </div>
  );
}

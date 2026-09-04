"use client";

import { useEffect, useState, useRef } from "react";
import styles from "./EasterEggs.module.css";
import { setSiteTheme } from "@/lib/theme";
import {
  unlockAchievement,
  type Achievement,
  ACHIEVEMENTS,
} from "@/lib/progression";

export default function EasterEggs() {
  const [zeroFlash, setZeroFlash] = useState(false);
  const [oneFlash, setOneFlash] = useState(false);
  const [forkingState, setForkingState] = useState<"forking" | "denied" | null>(null);
  const [modeTransition, setModeTransition] = useState<"zero" | "one" | null>(null);
  const [idleState, setIdleState] = useState<"15s" | "30s" | null>(null);
  const [resumedAfterIdle, setResumedAfterIdle] = useState(false);
  const [currentToast, setCurrentToast] = useState<Achievement | null>(null);
  const [showAllAchModal, setShowAllAchModal] = useState(false);
  const [spawnedPingus, setSpawnedPingus] = useState<number[]>([]);

  const idleTimer15 = useRef<NodeJS.Timeout | null>(null);
  const idleTimer30 = useRef<NodeJS.Timeout | null>(null);
  const resumeTimer = useRef<NodeJS.Timeout | null>(null);
  const toastTimer = useRef<NodeJS.Timeout | null>(null);
  const hadIdleRef = useRef(false);

  // 1. DevTools Console Hook and window API
  useEffect(() => {
    console.log(
      `%cyou found the console.\ncongrats, debugger.\n\ntry:\n  ihatebaselines.zero()\n  ihatebaselines.one()\n  ihatebaselines.pingu()`,
      "font-family: monospace; font-size: 13px; font-weight: 700; color: #10b981; line-height: 1.5;"
    );

    function spawnPingu() {
      const id = Date.now();
      setSpawnedPingus((prev) => [...prev, id]);
      setTimeout(() => {
        setSpawnedPingus((prev) => prev.filter((p) => p !== id));
      }, 5200);
    }

    if (typeof window !== "undefined") {
      (window as unknown as { ihatebaselines: Record<string, unknown> }).ihatebaselines = {
        zero: () => {
          setSiteTheme("zero", true);
          unlockAchievement(0);
          return "0: dark void activated.";
        },
        one: () => {
          setSiteTheme("one", true);
          unlockAchievement(1);
          return "1: something. white theme activated.";
        },
        pingu: () => {
          spawnPingu();
          unlockAchievement(3);
          return "🐧 pingu spawned.";
        },
        achievements: () => {
          unlockAchievement(4);
          return ACHIEVEMENTS;
        },
      };
    }

    // Reading console or running properties is reading source
    const handleConsoleInspect = () => {
      unlockAchievement(4);
    };
    window.addEventListener("ihateb-source-read", handleConsoleInspect);
    window.addEventListener("ihateb-spawn-pingu", spawnPingu);

    return () => {
      window.removeEventListener("ihateb-source-read", handleConsoleInspect);
      window.removeEventListener("ihateb-spawn-pingu", spawnPingu);
    };
  }, []);

  // 2. Mode Transition and Achievement Event Listeners
  useEffect(() => {
    function handleModeTransition(e: Event) {
      const detail = (e as CustomEvent).detail;
      setModeTransition(detail?.mode || "one");
      setTimeout(() => setModeTransition(null), 1250);
    }

    function handleAchievementUnlocked(e: Event) {
      const detail = (e as CustomEvent).detail;
      if (detail?.achievement) {
        if (toastTimer.current) clearTimeout(toastTimer.current);
        setCurrentToast(detail.achievement);
        toastTimer.current = setTimeout(() => setCurrentToast(null), 3200);
      }
    }

    function handleAllAchievements() {
      setShowAllAchModal(true);
      setTimeout(() => setShowAllAchModal(false), 5500);
    }

    window.addEventListener("trigger-mode-transition", handleModeTransition);
    window.addEventListener("achievement-unlocked", handleAchievementUnlocked);
    window.addEventListener("all-achievements-unlocked", handleAllAchievements);

    return () => {
      window.removeEventListener("trigger-mode-transition", handleModeTransition);
      window.removeEventListener("achievement-unlocked", handleAchievementUnlocked);
      window.removeEventListener("all-achievements-unlocked", handleAllAchievements);
      if (toastTimer.current) clearTimeout(toastTimer.current);
    };
  }, []);

  // 3. Keyboard Shortcut Handlers (0, 1, F)
  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      const target = e.target as HTMLElement;
      if (
        target.tagName === "INPUT" ||
        target.tagName === "TEXTAREA" ||
        target.isContentEditable
      ) {
        return;
      }

      if (e.key === "0") {
        setZeroFlash(true);
        setTimeout(() => setZeroFlash(false), 400);
        setSiteTheme("zero", true);
        unlockAchievement(0);
      } else if (e.key === "1") {
        setOneFlash(true);
        setTimeout(() => setOneFlash(false), 500);
        setSiteTheme("one", true);
        unlockAchievement(1);
      } else if (e.key === "f" || e.key === "F") {
        setForkingState("forking");
        setTimeout(() => {
          setForkingState("denied");
        }, 550);
        setTimeout(() => {
          setForkingState(null);
        }, 1200);
      }
    }

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  // 4. Idle Detection (15s -> "nothing is happening.", 30s -> "baseline remains undefeated.", mouse move -> "there you are.")
  useEffect(() => {
    function handleActivity() {
      if (hadIdleRef.current) {
        hadIdleRef.current = false;
        setIdleState(null);
        setResumedAfterIdle(true);
        if (resumeTimer.current) clearTimeout(resumeTimer.current);
        resumeTimer.current = setTimeout(() => {
          setResumedAfterIdle(false);
        }, 2200);
      }

      if (idleTimer15.current) clearTimeout(idleTimer15.current);
      if (idleTimer30.current) clearTimeout(idleTimer30.current);

      idleTimer15.current = setTimeout(() => {
        hadIdleRef.current = true;
        setIdleState("15s");
      }, 15000);

      idleTimer30.current = setTimeout(() => {
        hadIdleRef.current = true;
        setIdleState("30s");
      }, 30000);
    }

    handleActivity();

    window.addEventListener("mousemove", handleActivity, { passive: true });
    window.addEventListener("scroll", handleActivity, { passive: true });
    window.addEventListener("keydown", handleActivity, { passive: true });
    window.addEventListener("touchstart", handleActivity, { passive: true });

    return () => {
      if (idleTimer15.current) clearTimeout(idleTimer15.current);
      if (idleTimer30.current) clearTimeout(idleTimer30.current);
      if (resumeTimer.current) clearTimeout(resumeTimer.current);
      window.removeEventListener("mousemove", handleActivity);
      window.removeEventListener("scroll", handleActivity);
      window.removeEventListener("keydown", handleActivity);
      window.removeEventListener("touchstart", handleActivity);
    };
  }, []);

  return (
    <>
      {/* Giant 0 Keypress Overlay (400ms) */}
      {zeroFlash && <div className={styles.giantZeroFlash}>0</div>}

      {/* 1 Keypress White Flash + "something." */}
      {oneFlash && (
        <div className={styles.giantOneFlash}>
          <div className={styles.giantOneText}>1</div>
          <div className={styles.giantOneSub}>something.</div>
        </div>
      )}

      {/* Mode Transition Overlay (0 -> 1 or 1 -> 0) */}
      {modeTransition === "one" && (
        <div className={styles.modeTransitionOverlay}>
          <div className={styles.modeTransStage}>
            <div className={styles.modeTransZero}>
              0<br />
              <span style={{ fontSize: "0.5em", fontWeight: 400, opacity: 0.8 }}>
                nothing.
              </span>
            </div>
            <div className={styles.modeTransArrow}>↓</div>
            <div className={styles.modeTransOne}>
              1<br />
              <span style={{ fontSize: "0.5em", fontWeight: 400, opacity: 0.9 }}>
                something.
              </span>
            </div>
            <div className={styles.modeTransMoved}>you moved.</div>
          </div>
          <div className={styles.modeTransLeftBehind}>baseline left behind.</div>
        </div>
      )}

      {modeTransition === "zero" && (
        <div className={styles.modeTransitionOverlay}>
          <div className={styles.modeTransStage}>
            <div className={styles.modeTransOne}>
              1<br />
              <span style={{ fontSize: "0.5em", fontWeight: 400, opacity: 0.9 }}>
                something.
              </span>
            </div>
            <div className={styles.modeTransArrow}>↓</div>
            <div className={styles.modeTransZero}>
              0<br />
              <span style={{ fontSize: "0.5em", fontWeight: 400, opacity: 0.8 }}>
                nothing.
              </span>
            </div>
            <div className={styles.modeTransMoved}>back to origin.</div>
          </div>
          <div className={styles.modeTransLeftBehind}>baseline restored.</div>
        </div>
      )}

      {/* F Key Forking Reality Alert */}
      {forkingState && (
        <div className={styles.forkingAlert}>
          <div className={styles.forkingMain}>forking reality...</div>
          {forkingState === "denied" && (
            <div className={styles.forkingDenied}>permission denied.</div>
          )}
        </div>
      )}

      {/* Idle Status Pills */}
      {idleState === "15s" && (
        <div className={styles.idlePill}>
          <span className={styles.idleBlinkDot} />
          <span>nothing is happening.</span>
        </div>
      )}

      {idleState === "30s" && (
        <div className={styles.idlePill}>
          <span className={styles.idleBlinkDot} />
          <span>baseline remains undefeated.</span>
        </div>
      )}

      {/* Resume after Idle */}
      {resumedAfterIdle && (
        <div className={styles.mouseBackPill}>
          <span>there you are.</span>
        </div>
      )}

      {/* Achievement Toast */}
      {currentToast && (
        <div className={styles.achievementToast}>
          <div className={styles.achievementTitle}>{currentToast.label}</div>
          <div className={styles.achievementDesc}>{currentToast.description}</div>
        </div>
      )}

      {/* All 6 Achievements Modal */}
      {showAllAchModal && (
        <div className={styles.allAchievementsModal}>
          <div className={styles.allAchTitle}>6/6</div>
          <div className={styles.allAchSub}>
            you spent way too much time here.
          </div>
          <div className={styles.allAchRespect}>respect.</div>
        </div>
      )}

      {/* Dynamically spawned pingus */}
      {spawnedPingus.map((id) => (
        <img
          key={id}
          src="/images/pingu-waving.png"
          alt="Spawned Pingu"
          className={styles.spawnedPinguSprite}
        />
      ))}
    </>
  );
}

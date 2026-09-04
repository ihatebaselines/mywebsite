"use client";

import React, { useState, useMemo } from "react";
import {
  History,
  Tag,
  CheckCircle2,
  Calendar,
  Sparkles,
  Search,
  Filter,
} from "lucide-react";
import { changelog, ChangelogEntry } from "@/content/changelog";
import { unlockAchievement } from "@/lib/progression";
import styles from "@/app/page.module.css";

export default function ChangelogTimeline() {
  const [selectedTag, setSelectedTag] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [versionClicks, setVersionClicks] = useState(0);
  const [showV0, setShowV0] = useState(false);

  const filteredEntries = useMemo(() => {
    return changelog.filter((entry) => {
      const matchesTag =
        selectedTag === "all" ||
        entry.tagType === selectedTag ||
        entry.tag.toLowerCase().includes(selectedTag.toLowerCase());

      const matchesSearch =
        !searchQuery.trim() ||
        `${entry.title} ${entry.summary} ${entry.version} ${entry.changes.join(" ")}`
          .toLowerCase()
          .includes(searchQuery.toLowerCase());

      return matchesTag && matchesSearch;
    });
  }, [selectedTag, searchQuery]);

  const handleVersionClick = (version: string) => {
    if (version === "v2.6.7" || version.includes("2.6.7") || version === "v2.5" || version.includes("2.5")) {
      const next = versionClicks + 1;
      setVersionClicks(next);
      if (next >= 4) {
        setShowV0(true);
        unlockAchievement(0);
      }
    }
  };

  return (
    <div className={styles.changelogContainer}>
      {/* Search & Filter Bar */}
      <div className={styles.changelogToolbar}>
        <div className={styles.changelogSearchBox}>
          <Search size={16} className={styles.changelogSearchIcon} />
          <input
            type="text"
            placeholder="Search updates, releases, features..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className={styles.changelogInput}
          />
        </div>

        <div className={styles.changelogFilterPills}>
          <button
            type="button"
            className={`${styles.changelogPill} ${selectedTag === "all" ? styles.changelogPillActive : ""}`}
            onClick={() => setSelectedTag("all")}
          >
            All Updates ({changelog.length})
          </button>
          <button
            type="button"
            className={`${styles.changelogPill} ${selectedTag === "competition" ? styles.changelogPillActive : ""}`}
            onClick={() => setSelectedTag("competition")}
          >
            🏆 Competitions
          </button>
          <button
            type="button"
            className={`${styles.changelogPill} ${selectedTag === "feature" ? styles.changelogPillActive : ""}`}
            onClick={() => setSelectedTag("feature")}
          >
            ✨ Features & UI
          </button>
          <button
            type="button"
            className={`${styles.changelogPill} ${selectedTag === "milestone" ? styles.changelogPillActive : ""}`}
            onClick={() => setSelectedTag("milestone")}
          >
            🚀 Experiences
          </button>
        </div>
      </div>

      {/* Vertical Timeline */}
      <div className={styles.timeline}>
        {filteredEntries.map((entry) => {
          const isCompetition = entry.tagType === "competition";
          const isFeature = entry.tagType === "feature";

          return (
            <article key={entry.version} className={styles.timelineItem}>
              {/* Timeline Node */}
              <div className={styles.timelineLine}>
                <div
                  className={`${styles.timelineNode} ${
                    isCompetition
                      ? styles.timelineNodeGold
                      : isFeature
                      ? styles.timelineNodeMauve
                      : styles.timelineNodeTeal
                  }`}
                >
                  <span className={styles.timelineNodeDot} />
                </div>
              </div>

              {/* Timeline Card */}
              <div className={styles.timelineContent}>
                <div className={styles.timelineCardHeader}>
                  <div className={styles.timelineVersionWrap}>
                    <span
                      className={styles.timelineVersion}
                      onClick={() => handleVersionClick(entry.version)}
                      title="Click repeatedly to trace back to origin"
                      style={{ cursor: "pointer" }}
                    >
                      {entry.version}
                    </span>
                    <span
                      className={`${styles.timelineTag} ${
                        isCompetition
                          ? styles.timelineTagGold
                          : isFeature
                          ? styles.timelineTagMauve
                          : styles.timelineTagTeal
                      }`}
                    >
                      {entry.tag}
                    </span>
                  </div>

                  <div className={styles.timelineDate}>
                    <Calendar size={13} />
                    <span>{entry.date}</span>
                  </div>
                </div>

                <h3 className={styles.timelineTitle}>{entry.title}</h3>
                <p className={styles.timelineSummary} style={{ whiteSpace: "pre-line" }}>{entry.summary}</p>

                <ul className={styles.timelineChangeList}>
                  {entry.changes.map((change, cIdx) => (
                    <li key={cIdx} className={styles.timelineChangeItem}>
                      <CheckCircle2 size={15} className={styles.timelineCheckIcon} />
                      <span>{change}</span>
                    </li>
                  ))}
                </ul>

                {entry.quote && (
                  <blockquote
                    style={{
                      marginTop: "16px",
                      paddingLeft: "14px",
                      borderLeft: "2px solid rgba(255, 255, 255, 0.22)",
                      fontStyle: "italic",
                      color: "var(--text-muted)",
                      fontFamily: "var(--font)",
                      fontSize: "12.5px",
                      lineHeight: "1.6",
                      whiteSpace: "pre-line",
                    }}
                  >
                    {entry.quote}
                  </blockquote>
                )}
              </div>
            </article>
          );
        })}

        {/* Easter Egg 1: v0.0 revealed on repeated clicks */}
        {showV0 && (
          <article className={styles.timelineItem}>
            <div className={styles.timelineLine}>
              <div className={styles.timelineNode} style={{ borderColor: "#10b981" }}>
                <span className={styles.timelineNodeDot} style={{ background: "#10b981" }} />
              </div>
            </div>

            <div
              className={styles.timelineContent}
              style={{
                borderStyle: "dashed",
                borderColor: "rgba(16, 185, 129, 0.4)",
              }}
            >
              <div className={styles.timelineCardHeader}>
                <div className={styles.timelineVersionWrap}>
                  <span className={styles.timelineVersion} style={{ color: "#10b981" }}>
                    v0.0 — Genesis
                  </span>
                  <span className={styles.timelineTag} style={{ color: "#10b981" }}>
                    origin
                  </span>
                </div>
                <div className={styles.timelineDate}>
                  <Calendar size={13} />
                  <span>before anyone was looking</span>
                </div>
              </div>

              <h3 className={styles.timelineTitle}>initial commit.</h3>
              <p className={styles.timelineSummary} style={{ whiteSpace: "pre-line" }}>
                0 → 1
              </p>

              <ul className={styles.timelineChangeList}>
                <li className={styles.timelineChangeItem}>
                  <CheckCircle2 size={15} color="#10b981" />
                  <span>added nothing.</span>
                </li>
                <li className={styles.timelineChangeItem}>
                  <CheckCircle2 size={15} color="#10b981" />
                  <span>broke nothing.</span>
                </li>
                <li className={styles.timelineChangeItem}>
                  <CheckCircle2 size={15} color="#10b981" />
                  <span>started anyway.</span>
                </li>
              </ul>
            </div>
          </article>
        )}

        {/* Easter Egg 2: v∞ always hidden at the bottom */}
        <article className={styles.timelineItem}>
          <div className={styles.timelineLine}>
            <div className={styles.timelineNode} style={{ borderColor: "#888" }}>
              <span className={styles.timelineNodeDot} style={{ background: "#888" }} />
            </div>
          </div>

          <div
            className={styles.timelineContent}
            style={{
              opacity: 0.85,
              borderStyle: "dashed",
            }}
          >
            <div className={styles.timelineCardHeader}>
              <div className={styles.timelineVersionWrap}>
                <span className={styles.timelineVersion}>v∞ — Horizon</span>
                <span className={styles.timelineTag}>always</span>
              </div>
              <div className={styles.timelineDate}>
                <Calendar size={13} />
                <span>always</span>
              </div>
            </div>

            <h3 className={styles.timelineTitle}>still unfinished.</h3>
            <p className={styles.timelineSummary} style={{ whiteSpace: "pre-line" }}>
              There will always be another version.{"\n\n"}
              There will always be another thing to learn.{"\n\n"}
              There will always be another baseline.
            </p>

            <ul className={styles.timelineChangeList}>
              <li className={styles.timelineChangeItem}>
                <CheckCircle2 size={15} className={styles.timelineCheckIcon} />
                <span>loss → 0</span>
              </li>
              <li className={styles.timelineChangeItem}>
                <CheckCircle2 size={15} className={styles.timelineCheckIcon} />
                <span>curiosity → ∞</span>
              </li>
              <li className={styles.timelineChangeItem}>
                <CheckCircle2 size={15} className={styles.timelineCheckIcon} />
                <span>finished = false</span>
              </li>
            </ul>

            <blockquote
              style={{
                marginTop: "16px",
                paddingLeft: "14px",
                borderLeft: "2px solid rgba(255, 255, 255, 0.22)",
                fontStyle: "italic",
                color: "var(--text-muted)",
                fontFamily: "var(--font)",
                fontSize: "12.5px",
                lineHeight: "1.6",
                whiteSpace: "pre-line",
              }}
            >
              a baseline is just a suggestion to go further.{"\n\n"}
              <strong style={{ color: "var(--text)" }}>I hate baselines 💔</strong>
            </blockquote>
          </div>
        </article>
      </div>
    </div>
  );
}

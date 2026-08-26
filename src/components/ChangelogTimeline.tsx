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
import styles from "@/app/page.module.css";

export default function ChangelogTimeline() {
  const [selectedTag, setSelectedTag] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");

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
        {filteredEntries.map((entry, idx) => {
          const isCompetition = entry.tagType === "competition";
          const isFeature = entry.tagType === "feature";
          const isMilestone = entry.tagType === "milestone";

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
                    <span className={styles.timelineVersion}>{entry.version}</span>
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
                <p className={styles.timelineSummary}>{entry.summary}</p>

                <ul className={styles.timelineChangeList}>
                  {entry.changes.map((change, cIdx) => (
                    <li key={cIdx} className={styles.timelineChangeItem}>
                      <CheckCircle2 size={15} className={styles.timelineCheckIcon} />
                      <span>{change}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}

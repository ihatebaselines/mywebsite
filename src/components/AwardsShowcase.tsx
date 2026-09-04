"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import Tilt from "react-parallax-tilt";
import {
  Trophy,
  Medal,
  Award,
  ExternalLink,
  Sparkles,
  Flame,
  Clock,
  Coins,
  ArrowUpRight,
  Filter,
} from "lucide-react";
import { awards, getAwardsStats, AwardItem } from "@/content/awards";
import styles from "@/app/page.module.css";

export default function AwardsShowcase() {
  const [activeFilter, setActiveFilter] = useState<string>("all");
  const stats = useMemo(() => getAwardsStats(), []);

  const filteredAwards = useMemo(() => {
    if (activeFilter === "all") return awards;
    if (activeFilter === "podium") {
      return awards.filter((a) => a.tier === "gold" || a.tier === "silver" || a.tier === "bronze");
    }
    if (activeFilter === "ai") {
      return awards.filter(
        (a) =>
          a.category.includes("AI") ||
          a.category.includes("Olympiad") ||
          a.tags.some((t) => t.includes("AI") || t.includes("ML"))
      );
    }
    if (activeFilter === "hackathon") {
      return awards.filter((a) => a.category.includes("Hackathon") || a.tags.includes("Hackathon"));
    }
    return awards;
  }, [activeFilter]);

  return (
    <div className={styles.awardsContainer}>
      {/* Quick Stats Grid */}
      <div className={styles.awardsStatsRow}>
        <div className={styles.awardsStatCard}>
          <div className={styles.awardsStatIcon} style={{ color: "#f9e2af" }}>
            <Trophy size={22} />
          </div>
          <div className={styles.awardsStatMeta}>
            <span className={styles.awardsStatValue}>{stats.podiums}</span>
            <span className={styles.awardsStatLabel}>Podiums Won</span>
          </div>
        </div>

        <div className={styles.awardsStatCard}>
          <div className={styles.awardsStatIcon} style={{ color: "#fab387" }}>
            <Medal size={22} />
          </div>
          <div className={styles.awardsStatMeta}>
            <span className={styles.awardsStatValue}>{stats.firstPlaces}</span>
            <span className={styles.awardsStatLabel}>1st Place Golds</span>
          </div>
        </div>

        <div className={styles.awardsStatCard}>
          <div className={styles.awardsStatIcon} style={{ color: "#a6e3a1" }}>
            <Coins size={22} />
          </div>
          <div className={styles.awardsStatMeta}>
            <span className={styles.awardsStatValue}>{stats.prizeMoney}</span>
            <span className={styles.awardsStatLabel}>Prizes Won</span>
          </div>
        </div>

        <div className={styles.awardsStatCard}>
          <div className={styles.awardsStatIcon} style={{ color: "#f5f0eb" }}>
            <Clock size={22} />
          </div>
          <div className={styles.awardsStatMeta}>
            <span className={styles.awardsStatValue}>{stats.hackathons}</span>
            <span className={styles.awardsStatLabel}>Hackathon Sprint</span>
          </div>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className={styles.awardsFilterRow}>
        <div className={styles.awardsFilterGroup}>
          <button
            type="button"
            className={`${styles.awardsFilterBtn} ${activeFilter === "all" ? styles.awardsFilterBtnActive : ""}`}
            onClick={() => setActiveFilter("all")}
          >
            All Achievements ({awards.length})
          </button>
          <button
            type="button"
            className={`${styles.awardsFilterBtn} ${activeFilter === "podium" ? styles.awardsFilterBtnActive : ""}`}
            onClick={() => setActiveFilter("podium")}
          >
            🏆 Podiums Only ({stats.podiums})
          </button>
          <button
            type="button"
            className={`${styles.awardsFilterBtn} ${activeFilter === "ai" ? styles.awardsFilterBtnActive : ""}`}
            onClick={() => setActiveFilter("ai")}
          >
            🧠 AI & Olympiads
          </button>
          <button
            type="button"
            className={`${styles.awardsFilterBtn} ${activeFilter === "hackathon" ? styles.awardsFilterBtnActive : ""}`}
            onClick={() => setActiveFilter("hackathon")}
          >
            ⚡ Hackathons
          </button>
        </div>
      </div>

      {/* Awards Bento Grid with 3D Tilt */}
      <div className={styles.awardsGrid}>
        {filteredAwards.map((item) => {
          const isGold = item.tier === "gold";
          const isSilver = item.tier === "silver";
          const isBronze = item.tier === "bronze";

          return (
            <Tilt
              key={item.id}
              tiltMaxAngleX={6}
              tiltMaxAngleY={6}
              glareEnable={false}
              scale={1.01}
              transitionSpeed={300}
              className={`${styles.awardCard} ${
                isGold
                  ? styles.awardCardGold
                  : isSilver
                  ? styles.awardCardSilver
                  : isBronze
                  ? styles.awardCardBronze
                  : ""
              }`}
            >
              <div className={styles.awardCardTop}>
                <div className={styles.awardBadgeWrap}>
                  <span
                    className={`${styles.awardBadge} ${
                      isGold
                        ? styles.awardBadgeGold
                        : isSilver
                        ? styles.awardBadgeSilver
                        : isBronze
                        ? styles.awardBadgeBronze
                        : styles.awardBadgeSpecial
                    }`}
                  >
                    {item.badge}
                  </span>
                  <span className={styles.awardDate}>{item.date}</span>
                </div>

                {item.score && (
                  <span className={styles.awardScoreBadge}>{item.score}</span>
                )}
              </div>

              <div className={styles.awardCardBody}>
                <h3 className={styles.awardTitle}>{item.title}</h3>
                <h4 className={styles.awardEvent}>{item.event}</h4>
                {item.division && (
                  <p className={styles.awardDivision}>{item.division}</p>
                )}
                <p className={styles.awardDesc}>{item.description}</p>
              </div>

              <div className={styles.awardCardFooter}>
                <div className={styles.awardTags}>
                  {item.tags.map((tag) => (
                    <span key={tag} className={styles.awardTag}>
                      {tag}
                    </span>
                  ))}
                </div>

                {item.links && item.links.length > 0 && (
                  <div className={styles.awardLinks}>
                    {item.links.map((link, idx) => (
                      <Link
                        key={idx}
                        href={link.url}
                        className={styles.awardLinkBtn}
                        target={link.url.startsWith("http") ? "_blank" : undefined}
                        rel={link.url.startsWith("http") ? "noreferrer" : undefined}
                      >
                        <span>{link.label}</span>
                        <ArrowUpRight size={13} />
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            </Tilt>
          );
        })}
      </div>
    </div>
  );
}

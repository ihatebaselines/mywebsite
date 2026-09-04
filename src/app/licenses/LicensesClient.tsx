"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { Search, ExternalLink, Package, X } from "lucide-react";
import SectionLabel from "@/components/home/SectionLabel";
import { unlockAchievement } from "@/lib/progression";
import styles from "./licenses.module.css";

function GithubIcon({ size = 13 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
      <path d="M9 18c-4.51 2-5-2-7-2" />
    </svg>
  );
}

export interface LicenseItem {
  name: string;
  version: string;
  license: string;
  licenseUrl: string;
  category: string;
  author: string;
  website: string;
  repository: string;
  npm: string | null;
  description: string;
}

const CATEGORIES = [
  "All",
  "Core Framework",
  "Animation & Physics",
  "3D & Graphics",
  "Backend & Database",
  "UI & Icons",
  "Typography & Typefaces",
  "Development Tooling",
];

export default function LicensesClient({
  initialLicenses,
}: {
  initialLicenses: LicenseItem[];
}) {
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [freeHover, setFreeHover] = useState(false);
  const [lockinHover, setLockinHover] = useState(false);
  const [mitClicks, setMitClicks] = useState(0);
  const [mitGranted, setMitGranted] = useState(false);

  const filteredLicenses = useMemo(() => {
    const q = search.trim().toLowerCase();
    return initialLicenses.filter((item) => {
      const matchCat =
        selectedCategory === "All" || item.category === selectedCategory;
      if (!matchCat) return false;

      if (!q) return true;
      return (
        item.name.toLowerCase().includes(q) ||
        item.description.toLowerCase().includes(q) ||
        item.license.toLowerCase().includes(q) ||
        item.author.toLowerCase().includes(q) ||
        item.category.toLowerCase().includes(q)
      );
    });
  }, [initialLicenses, search, selectedCategory]);

  const handleMitBadgeClick = (e: React.MouseEvent, license: string) => {
    if (license.toUpperCase().includes("MIT")) {
      const next = mitClicks + 1;
      setMitClicks(next);
      if (next >= 5) {
        e.preventDefault();
        setMitGranted(true);
        unlockAchievement(4);
        setTimeout(() => setMitGranted(false), 4500);
      }
    }
  };

  return (
    <main className={styles.licensesPage}>
      {/* Hero Section */}
      <section className={styles.heroSection}>
        <SectionLabel label="00 / OPEN SOURCE ATTRIBUTIONS" />
        <h1 className={styles.hugeTitle}>open source licenses.</h1>
        <p className={styles.heroSubtitle}>
          ihatebaselines is built on the shoulders of open source giants.
          A comprehensive directory of all libraries, tools, frameworks, and typefaces
          powering this digital space. Everything here is open and transparent.
        </p>

        <div className={styles.statsBar}>
          <div className={styles.statItem}>
            <span className={styles.statNum}>{initialLicenses.length}</span>
            <span>dependencies</span>
          </div>
          <span className={styles.statDot}>•</span>
          <div
            className={styles.statItem}
            onMouseEnter={() => setFreeHover(true)}
            onMouseLeave={() => setFreeHover(false)}
            style={{ cursor: "default" }}
          >
            <span className={styles.statNum}>100%</span>
            <span style={{ color: freeHover ? "#10b981" : "inherit" }}>
              {freeHover ? "as it should be." : "free & open source"}
            </span>
          </div>
          <span className={styles.statDot}>•</span>
          <div
            className={styles.statItem}
            onMouseEnter={() => setLockinHover(true)}
            onMouseLeave={() => setLockinHover(false)}
            style={{ cursor: "default" }}
          >
            <span className={styles.statNum}>0</span>
            <span style={{ color: lockinHover ? "#a855f7" : "inherit" }}>
              {lockinHover ? "beautiful." : "proprietary lock-in"}
            </span>
          </div>
        </div>
      </section>

      {/* Permission Granted Easter Egg Toast */}
      {mitGranted && (
        <div
          style={{
            position: "fixed",
            bottom: "30px",
            left: "50%",
            transform: "translateX(-50%)",
            background: "#141212",
            border: "1px solid rgba(16, 185, 129, 0.5)",
            borderRadius: "6px",
            padding: "12px 24px",
            fontFamily: "var(--font-jetbrains-mono, monospace)",
            color: "#10b981",
            fontSize: "13px",
            zIndex: 999999,
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.8)",
          }}
        >
          permission granted to do basically whatever.
        </div>
      )}

      {/* Controls Section */}
      <section className={styles.controlsSection}>
        <div className={styles.searchBarWrapper}>
          <Search size={16} className={styles.searchIcon} />
          <input
            type="text"
            className={styles.searchInput}
            placeholder="Search libraries by name, category, or author..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          {search && (
            <button
              type="button"
              className={styles.clearSearchBtn}
              onClick={() => setSearch("")}
              aria-label="Clear search"
            >
              <X size={14} />
            </button>
          )}
        </div>

        <div className={styles.categoryPills} role="tablist">
          {CATEGORIES.map((cat) => {
            const isActive = selectedCategory === cat;
            return (
              <button
                key={cat}
                type="button"
                role="tab"
                aria-selected={isActive}
                className={`${styles.categoryPill} ${
                  isActive ? styles.categoryPillActive : ""
                }`}
                onClick={() => setSelectedCategory(cat)}
              >
                {cat}
              </button>
            );
          })}
        </div>
      </section>

      {/* Grid of Licenses */}
      <section className={styles.gridSection}>
        <div className={styles.licensesGrid}>
          {filteredLicenses.length === 0 ? (
            <div className={styles.noResults}>
              <p>No libraries found matching &ldquo;{search}&rdquo;.</p>
            </div>
          ) : (
            filteredLicenses.map((item) => (
              <article key={item.name} className={styles.licenseCard}>
                <div className={styles.cardTop}>
                  <div className={styles.cardHeaderRow}>
                    <div className={styles.cardTitleWrap}>
                      <h2 className={styles.cardTitle}>{item.name}</h2>
                      <span className={styles.cardVersion}>{item.version}</span>
                    </div>

                    <a
                      href={item.licenseUrl}
                      target="_blank"
                      rel="noreferrer"
                      className={styles.licenseBadge}
                      title={`View ${item.license} license (Click 5 times)`}
                      onClick={(e) => handleMitBadgeClick(e, item.license)}
                    >
                      {item.license}
                    </a>
                  </div>

                  <div className={styles.cardAuthor}>by {item.author}</div>
                  <p className={styles.cardDescription}>{item.description}</p>
                  <span className={styles.cardCategoryTag}>{item.category}</span>
                </div>

                <div className={styles.cardBottomLinks}>
                  {item.repository && (
                    <a
                      href={item.repository}
                      target="_blank"
                      rel="noreferrer"
                      className={styles.cardActionLink}
                      title="GitHub Repository"
                    >
                      <GithubIcon size={13} />
                      <span>Repo</span>
                    </a>
                  )}

                  {item.website && (
                    <a
                      href={item.website}
                      target="_blank"
                      rel="noreferrer"
                      className={styles.cardActionLink}
                      title="Official Website"
                    >
                      <ExternalLink size={13} />
                      <span>Site</span>
                    </a>
                  )}

                  {item.npm && (
                    <a
                      href={item.npm}
                      target="_blank"
                      rel="noreferrer"
                      className={styles.cardActionLink}
                      title="NPM Package"
                    >
                      <Package size={13} />
                      <span>NPM</span>
                    </a>
                  )}
                </div>
              </article>
            ))
          )}
        </div>
      </section>

      {/* Lawyers were here footnote */}
      <div
        style={{
          textAlign: "center",
          fontFamily: "var(--font-jetbrains-mono, monospace)",
          fontSize: "10.5px",
          color: "var(--text-dim)",
          opacity: 0.4,
          padding: "50px 0 20px",
          userSelect: "none",
        }}
      >
        lawyers were here.
      </div>
    </main>
  );
}

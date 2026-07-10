import Link from "next/link";
import Navbar from "@/components/Navbar";
import GlowCard from "@/components/GlowCard";
import { getSortedOpenSource } from "@/content/opensource";
import styles from "@/app/page.module.css";

const LANGUAGE_COLORS: Record<string, string> = {
  Python: "#3572A5",
  TypeScript: "#3178c6",
  JavaScript: "#f1e05a",
  Rust: "#dea584",
  Go: "#00ADD8",
  Java: "#b07219",
  "C++": "#f34b7d",
};

export default function OpenSourcePage() {
  const items = getSortedOpenSource();

  return (
    <main className={styles.page}>
      <Navbar backHref="/" backLabel="Home" />

      <section className={styles.pageHero}>
        <div className={styles.pageHeroGlow} aria-hidden="true" />
        <div className={styles.sectionHeader} data-reveal>
          <p>Open Source</p>
          <h1 data-split-heading>code in the open</h1>
          <span className={styles.pageHeroSub}>
            Repos, tools, and experiments that are publicly available on
            GitHub. Contributions welcome.
          </span>
        </div>
      </section>

      <section className={styles.band}>
        <div className={styles.osGrid}>
          {items.map((item) => (
            <a
              key={item.slug}
              className={styles.osCard}
              href={item.repoUrl}
              target="_blank"
              rel="noreferrer"
              data-card
            >
              <div className={styles.osCardHeader}>
                <svg
                  className={styles.osGithubIcon}
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
                <span className={styles.osRepoName}>
                  {item.repoUrl.replace("https://github.com/", "")}
                </span>
              </div>

              {item.image ? (
                <div className={styles.osCardImage}>
                  <img
                    src={item.image}
                    alt=""
                    loading="lazy"
                    decoding="async"
                  />
                </div>
              ) : null}

              <h3>{item.name}</h3>
              <p>{item.description}</p>

              <div className={styles.osCardFooter}>
                <span
                  className={styles.osLanguageDot}
                  style={{
                    backgroundColor:
                      LANGUAGE_COLORS[item.language] || "#8b8b8b",
                  }}
                />
                <span className={styles.osLanguage}>{item.language}</span>
                <div className={styles.osTopics}>
                  {item.topics.slice(0, 4).map((topic) => (
                    <span key={topic} className={styles.osTopic}>
                      {topic}
                    </span>
                  ))}
                </div>
              </div>
            </a>
          ))}
        </div>
      </section>

      <section className={styles.band}>
        <div className={styles.osContribCta} data-reveal>
          <h2 data-split-heading>want to contribute?</h2>
          <p>
            All repos are open for issues, PRs, and discussions. If you
            find something interesting, fork it and build on it.
          </p>
          <a
            className={styles.projectButton}
            href="https://github.com/ihatebaselines"
            target="_blank"
            rel="noreferrer"
          >
            GitHub profile
          </a>
        </div>
      </section>
    </main>
  );
}

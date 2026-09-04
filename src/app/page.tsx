"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import LeaderboardRank from "@/components/LeaderboardRank";
import SectionLabel from "@/components/home/SectionLabel";
import BackgroundMarquee from "@/components/home/BackgroundMarquee";
import PenguinDraggable from "@/components/home/PenguinDraggable";
import DraggableWavingPenguin from "@/components/home/DraggableWavingPenguin";
import ProjectCard from "@/components/home/ProjectCard";
import { CompetitionCard, BlogArticleCard } from "@/components/home/EditorialCard";
import ScrollReveal from "@/components/home/ScrollReveal";
import { getInitialTheme, type SiteMode } from "@/lib/theme";
import { unlockAchievement } from "@/lib/progression";

import workData from "@/content/workData.json";
import postsData from "@/content/postsData.json";

import styles from "./page.module.css";

export default function Home() {
  const [theme, setTheme] = useState<SiteMode>("zero");
  const [projectsTitleHover, setProjectsTitleHover] = useState(false);
  const [baselineBroken, setBaselineBroken] = useState(false);
  const [baselineHover, setBaselineHover] = useState(false);

  // Sync theme
  useEffect(() => {
    setTheme(getInitialTheme());
    const handleThemeChange = (e: Event) => {
      const detail = (e as CustomEvent).detail;
      if (detail?.mode) setTheme(detail.mode);
    };
    window.addEventListener("theme-change", handleThemeChange);
    return () => window.removeEventListener("theme-change", handleThemeChange);
  }, []);

  // Real data references
  const projects = workData.slice(0, 4);
  const compPosts = postsData.slice(0, 4);

  const handleBaselineClick = () => {
    setBaselineBroken((prev) => !prev);
    unlockAchievement(2);
  };

  return (
    <main className={styles.page}>
      {/* Sticky Compact Header */}
      <Navbar />

      {/* ═══════════════════════════════════════════════════════
          SECTION 01 — HERO
          ═══════════════════════════════════════════════════════ */}
      <section className={styles.hero} aria-label="Hero section">
        <PenguinDraggable />

        {/* Massive Watermark Typography matching Screenshot 1 */}
        {theme === "one" && (
          <>
            <div className={styles.heroWatermarkLeft} aria-hidden="true">
              ONE
              <br />
              BEGIN
            </div>
            <div className={styles.heroWatermarkRight} aria-hidden="true">
              START
              <br />
              FROM
              <br />
              ZERO
            </div>

            <div className={`${styles.heroAnnotation} ${styles.heroAnnotationTopLeft}`} aria-hidden="true">
              0 was the origin.
            </div>
            <div className={`${styles.heroAnnotation} ${styles.heroAnnotationBotLeft}`} aria-hidden="true">
              start &gt; perfect.
            </div>
            <div className={`${styles.heroAnnotation} ${styles.heroAnnotationMidRight}`} aria-hidden="true">
              1 is enough to begin.
            </div>
          </>
        )}

        <div className={styles.heroCopy}>
          <div className={styles.kicker}>you can drag the pingus. :))</div>

          <h1 className={styles.heroTitleNew}>
            {theme === "one" ? (
              <>
                <span>1 means</span>
                <span>begin again.</span>
              </>
            ) : (
              <>
                <span>i hate</span>
                <span>baselines.</span>
              </>
            )}
          </h1>

          <p className={styles.heroSubtitleNew}>
            {theme === "one" ? (
              <>
                student developer building AI, open source,
                <br />
                and things that start after zero.
              </>
            ) : (
              <>
                student developer building AI, open source,
                <br />
                and things that start at zero.
              </>
            )}
          </p>

          <div className={styles.heroActionRowNew}>
            <a className={styles.heroActionBtnNew} href="#projects">
              <span>See work →</span>
            </a>
            <Link className={styles.heroActionBtnNew} href="/opensource">
              <span>Open Source →</span>
            </Link>
            <a
              className={styles.heroActionBtnNew}
              href="https://www.linkedin.com/in/vladandreirus"
              target="_blank"
              rel="noreferrer"
            >
              <span>LinkedIn →</span>
            </a>
          </div>

          <div className={styles.heroMetricsRowNew}>
            {theme === "one" ? (
              <>
                <span>04 — mlcompete</span>
                <span className={styles.metricSepNew}>|</span>
                <span>0 — origin</span>
                <span className={styles.metricSepNew}>|</span>
                <span>1 — a new beginning</span>
              </>
            ) : (
              <>
                <span>04 — mlcompete</span>
                <span className={styles.metricSepNew}>|</span>
                <span>0 — username</span>
                <span className={styles.metricSepNew}>|</span>
                <span>∞ — ideas</span>
              </>
            )}
          </div>
        </div>
      </section>

      {/* ═══════════════════════════════════════════════════════
          SECTION 01 — ABOUT / RESEARCH
          ═══════════════════════════════════════════════════════ */}
      {/* Background outline typography watermark */}
      <BackgroundMarquee />

      <section id="about" className={styles.aboutSection}>
        <ScrollReveal>
          <div className={styles.aboutContainer} data-card>
            <div className={styles.aboutHeader}>
              <div className={styles.aboutEditorialLabel}>
                <span className={styles.aboutLabelNum}>01</span>
                <span className={styles.aboutLabelSlash}>/</span>
                <span className={styles.aboutLabelTitle}>README.MD</span>
              </div>
              <LeaderboardRank />
            </div>
            <p className={styles.aboutBio}>
              Student based in Cluj-Napoca, studying at Colegiul National
              &quot;Emil Racovita&quot;. Lowkey I am deeply interested in AI
              architectures, competitive programming, mathematics, research,
              and building things from zero.
            </p>
          </div>

          <div className={styles.aboutBottomBarNew}>
            <span className={styles.aboutBottomLeftNew}>0 is still a number.</span>
            <span className={styles.aboutBottomRightNew}>01 — README.MD</span>
          </div>
        </ScrollReveal>
      </section>

      {/* ═══════════════════════════════════════════════════════
          SECTION 02 — PROJECTS
          ═══════════════════════════════════════════════════════ */}
      <section id="projects" className={styles.projectsSectionNew}>
        <div id="last-work" style={{ position: "relative", top: "-80px" }} />

        <div className={styles.projectsContainerNew}>
          {/* Left Column: Title + Bio + Pingu */}
          <ScrollReveal className={styles.projectsLeftColNew}>
            <SectionLabel label="02 / PROJECTS" />
            <h2
              className={styles.projectsHugeTitleNew}
              onMouseEnter={() => setProjectsTitleHover(true)}
              onMouseLeave={() => setProjectsTitleHover(false)}
              style={{ cursor: "default" }}
              title="hover to see origin thoughts"
            >
              {projectsTitleHover ? (
                <>
                  things I
                  <br />
                  broke first.
                </>
              ) : (
                <>
                  some
                  <br />
                  things.
                </>
              )}
            </h2>
            <p className={styles.projectsSubtitleNew}>
              projects, experiments, and
              <br />
              ideas that somehow worked.
            </p>
            <Link className={styles.seeAllWorkBtnNew} href="/work">
              See all work →
            </Link>

            {/* Draggable Pingu with card drop code review */}
            <DraggableWavingPenguin />

            {/* Subtle empty space whisper */}
            <div className={styles.someSurvivedText}>some survived.</div>
          </ScrollReveal>

          {/* Right Column: 2-column project grid with real repo content */}
          <div className={styles.projectsRightColNew}>
            <div className={styles.projectsGrid2x2New}>
              {projects.map((item, index) => (
                <ScrollReveal key={item.slug} delay={index * 0.08}>
                  <div data-project-card="true">
                    <ProjectCard
                      slug={item.slug}
                      title={item.title}
                      date={item.date}
                      category={item.tag}
                      description={item.summary}
                      image={item.image}
                    />
                  </div>
                </ScrollReveal>
              ))}
            </div>

            {/* Bottom-right subtle easter egg label with broken line effect */}
            <div className={styles.baselineNoteWrapNew}>
              <span
                className={`${styles.baselineNoteNew} ${styles.brokenLineEffect} ${
                  baselineBroken ? styles.baselineBrokenLine : ""
                }`}
                onClick={handleBaselineClick}
                onMouseEnter={() => setBaselineHover(true)}
                onMouseLeave={() => setBaselineHover(false)}
                title="Click to break the baseline."
              >
                {baselineBroken
                  ? "baseline broken. ⚡"
                  : baselineHover
                  ? "break the baseline."
                  : "baseline detected."}
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* ═══════════════════════════════════════════════════════
          SECTION 04 — COMPETITIONS / HIGHLIGHTS
          ═══════════════════════════════════════════════════════ */}
      <section id="highlights" className={styles.highlightsSectionNew}>
        <ScrollReveal>
          <SectionLabel label="03 / HIGHLIGHTS" />
          <h2 className={styles.projectsHugeTitleNew}>
            recent
            <br />
            competitions /
            <br />
            hackathons
          </h2>
        </ScrollReveal>

        <div className={styles.highlightsGridNew}>
          {compPosts.map((post, idx) => (
            <ScrollReveal key={post.slug} delay={idx * 0.08}>
              <CompetitionCard
                number={String(idx + 1).padStart(2, "0")}
                category={post.category}
                date={post.date}
                title={post.title}
                description={post.shortStory}
                slug={post.slug}
                isWide={idx === 0}
                extraMeta={idx === 0 ? "loss: 0.042 · Ego: NaN" : undefined}
              />
            </ScrollReveal>
          ))}
        </div>
      </section>

      {/* ═══════════════════════════════════════════════════════
          SECTION 05 — BLOG
          ═══════════════════════════════════════════════════════ */}
      <section id="blog" className={styles.blogSectionNew}>
        <ScrollReveal className={styles.blogHeaderRowNew}>
          <div>
            <SectionLabel label="04 / BLOG" />
            <h2
              className={styles.projectsHugeTitleNew}
              style={{ marginBottom: 0 }}
            >
              basically just
              <br />
              random blogs I guess
            </h2>
          </div>
          <Link className={styles.seeAllWorkBtnNew} href="/blog">
            VIEW ALL POSTS →
          </Link>
        </ScrollReveal>

        <div className={styles.blogAsymGridNew}>
          {/* Left Column: Featured Card + 2 Sub-Cards */}
          <div className={styles.blogLeftColNew}>
            {postsData[0] && (
              <ScrollReveal>
                <BlogArticleCard
                  slug={postsData[0].slug}
                  title={postsData[0].title}
                  date={postsData[0].date}
                  category={postsData[0].category}
                  excerpt={postsData[0].excerpt}
                  image={postsData[0].cover}
                  variant="featured"
                />
              </ScrollReveal>
            )}

            <div className={styles.blogSubRowNew}>
              {postsData[3] && (
                <ScrollReveal delay={0.06}>
                  <BlogArticleCard
                    slug={postsData[3].slug}
                    title={postsData[3].title}
                    date={postsData[3].date}
                    category={postsData[3].category}
                    excerpt={postsData[3].excerpt}
                    image={postsData[3].cover}
                    variant="compact"
                  />
                </ScrollReveal>
              )}

              {postsData[4] && (
                <ScrollReveal delay={0.12}>
                  <BlogArticleCard
                    slug={postsData[4].slug}
                    title={postsData[4].title}
                    date={postsData[4].date}
                    category={postsData[4].category}
                    excerpt={postsData[4].excerpt}
                    image={postsData[4].cover}
                    variant="compact"
                  />
                </ScrollReveal>
              )}
            </div>
          </div>

          {/* Right Column: 3 Stacked Cards */}
          <div className={styles.blogRightColNew}>
            {postsData[1] && (
              <ScrollReveal delay={0.04}>
                <BlogArticleCard
                  slug={postsData[1].slug}
                  title={postsData[1].title}
                  date={postsData[1].date}
                  category={postsData[1].category}
                  excerpt={postsData[1].excerpt}
                  image={postsData[1].cover}
                  variant="stacked"
                />
              </ScrollReveal>
            )}

            {postsData[2] && (
              <ScrollReveal delay={0.08}>
                <BlogArticleCard
                  slug={postsData[2].slug}
                  title={postsData[2].title}
                  date={postsData[2].date}
                  category={postsData[2].category}
                  excerpt={postsData[2].excerpt}
                  image={postsData[2].cover}
                  variant="stacked"
                />
              </ScrollReveal>
            )}

            {postsData[5] && (
              <ScrollReveal delay={0.12}>
                <BlogArticleCard
                  slug={postsData[5].slug}
                  title={postsData[5].title}
                  date={postsData[5].date}
                  category={postsData[5].category}
                  excerpt={postsData[5].excerpt}
                  image={postsData[5].cover}
                  variant="stacked"
                />
              </ScrollReveal>
            )}
          </div>
        </div>
      </section>
    </main>
  );
}

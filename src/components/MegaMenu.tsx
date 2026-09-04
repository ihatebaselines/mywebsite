"use client";

import Link from "next/link";
import styles from "@/app/page.module.css";
import projectsData from "@/content/projectsData.json";
import opensourceData from "@/content/opensourceData.json";
import postsData from "@/content/postsData.json";

export default function MegaMenu({
  isOpen,
  onMouseEnter,
  onMouseLeave,
}: {
  isOpen: boolean;
  onMouseEnter: () => void;
  onMouseLeave: () => void;
}) {
  const featuredPost = postsData.find(p => p.slug === "from-algorithms-to-neurons") || postsData[0];
  const menuRecentPosts = [
    { title: "Algorithms to Neurons", slug: "from-algorithms-to-neurons" },
    { title: "Second Place at RISE", slug: "rise" },
    { title: "ROAI National Stage", slug: "roainationala" },
  ];

  return (
    <div
      className={`${styles.megaMenuPanel} ${isOpen ? styles.megaMenuOpen : ""}`}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      aria-hidden={!isOpen}
    >
      <div className={styles.megaMenuGrid}>
        {/* Column 1: Projects */}
        <div className={styles.megaMenuColumn}>
          <div className={styles.megaMenuHeaderRow}>
            <span className={styles.megaMenuHeader}>01. PROJECTS</span>
          </div>
          <div className={styles.megaMenuList}>
            {projectsData.map((project, idx) => (
              <Link href={`/projects#${project.slug}`} key={idx} className={styles.megaMenuLink}>
                <div className={styles.megaMenuIconWrap}>
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>
                </div>
                <span className={styles.megaMenuLinkText}>{project.title}</span>
                <span className={styles.megaMenuLinkArrow}>&rarr;</span>
              </Link>
            ))}
            <Link href="/projects" className={styles.megaMenuViewAll}>
              VIEW ALL PROJECTS &rarr;
            </Link>
          </div>
        </div>

        {/* Column 2: Open Source & Recent Posts */}
        <div className={styles.megaMenuColumn}>
          <div className={styles.megaMenuHeaderRow}>
            <span className={styles.megaMenuHeader}>02. OPEN SOURCE</span>
          </div>
          <div className={styles.megaMenuList}>
            {opensourceData.slice(0, 1).map((os, idx) => (
              <Link href="/opensource" key={idx} className={styles.megaMenuLink}>
                <div className={styles.megaMenuIconWrap}>
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                </div>
                <span className={styles.megaMenuLinkText}>{os.name}</span>
                <span className={styles.megaMenuLinkArrow}>&rarr;</span>
              </Link>
            ))}
            <Link href="/opensource" className={styles.megaMenuViewAll}>
              VIEW ALL PACKAGES &rarr;
            </Link>

            <div className={styles.megaMenuSubSection}>
              <span className={styles.megaMenuSubHeader}>RECENT POSTS</span>
              <div className={styles.megaMenuMiniList}>
                {menuRecentPosts.map((post) => (
                  <Link href={`/blog/${post.slug}`} key={post.slug} className={styles.megaMenuMiniLink}>
                    <span className={styles.megaMenuBullet}>&bull;</span>
                    <span className={styles.megaMenuMiniTitle}>{post.title}</span>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Column 3: Explore & Community */}
        <div className={styles.megaMenuColumn}>
          <div className={styles.megaMenuHeaderRow}>
            <span className={styles.megaMenuHeader}>03. EXPLORE</span>
          </div>
          <div className={styles.megaMenuList}>
            <Link href="/wall" className={styles.megaMenuLink}>
              <div className={styles.megaMenuIconWrap}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M12 19l7-7 3 3-7 7-3-3z"/><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"/><path d="M2 2l7.586 7.586"/><circle cx="11" cy="11" r="2"/></svg>
              </div>
              <span className={styles.megaMenuLinkText}>TheWall</span>
              <span className={styles.megaMenuLinkArrow}>&rarr;</span>
            </Link>
            <Link href="/blog" className={styles.megaMenuLink}>
              <div className={styles.megaMenuIconWrap}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
              </div>
              <span className={styles.megaMenuLinkText}>Blog & Stories</span>
              <span className={styles.megaMenuLinkArrow}>&rarr;</span>
            </Link>
            <Link href="/changelog" className={styles.megaMenuLink}>
              <div className={styles.megaMenuIconWrap}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
              </div>
              <span className={styles.megaMenuLinkText}>Changelog</span>
              <span className={styles.megaMenuLinkArrow}>&rarr;</span>
            </Link>

            <div className={styles.megaMenuSubSection}>
              <span className={styles.megaMenuSubHeader}>COMMUNITY</span>
              <div className={styles.megaMenuMiniList}>
                <a href="https://github.com/ihatebaselines" target="_blank" rel="noreferrer" className={styles.megaMenuMiniLink}>
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                  <span>GitHub Profile</span>
                </a>
                <a href="https://discordapp.com/users/934847546432581682" target="_blank" rel="noreferrer" className={styles.megaMenuMiniLink}>
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                  <span>Join Discord</span>
                </a>
              </div>
            </div>
          </div>
        </div>

        {/* Column 4: Feature Card */}
        <div className={styles.megaMenuFeature}>
          <div className={styles.megaMenuCard}>
            <div className={styles.megaMenuCardGraphic}>
              <img src={featuredPost.cover} alt={featuredPost.title} className={styles.megaMenuCardImg} />
            </div>
            <h4 className={styles.megaMenuCardTitle}>{featuredPost.title}</h4>
            <p className={styles.megaMenuCardDesc}>{featuredPost.excerpt}</p>
            <div className={styles.megaMenuCardActions}>
              <Link href={`/blog/${featuredPost.slug}`} className={styles.megaMenuBtnSolid}>
                Read Post
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* MegaMenu Bottom Info Bar */}
      <div className={styles.megaMenuFooterBar}>
        <span>ihatebaselines &bull; Work & Lab</span>
        <span>Cluj-Napoca &bull; Romania</span>
      </div>
    </div>
  );
}

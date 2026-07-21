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
  // Combine and find latest item
  const latestProject = [...projectsData].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())[0];
  const latestPost = [...postsData].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())[0];
  
  let latestItem = {
    title: latestProject.title,
    desc: latestProject.description,
    image: latestProject.image,
    link: `/projects#${latestProject.slug}`,
    actionText: "View Project",
    date: new Date(latestProject.date).getTime(),
    isPost: false
  };

  if (latestPost && new Date(latestPost.date).getTime() > latestItem.date) {
    latestItem = {
      title: latestPost.title,
      desc: latestPost.excerpt,
      image: latestPost.cover,
      link: `/blog/${latestPost.slug}`,
      actionText: "Read Post",
      date: new Date(latestPost.date).getTime(),
      isPost: true
    };
  }

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
          <span className={styles.megaMenuHeader}>PROJECTS</span>
          <div className={styles.megaMenuList}>
            {projectsData.map((project, idx) => (
              <Link href={`/projects#${project.slug}`} key={idx} className={styles.megaMenuLink}>
                <div className={styles.megaMenuIconWrap} style={{ color: "#10b981" }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>
                </div>
                {project.title}
              </Link>
            ))}
            <Link href="/projects" className={styles.megaMenuViewAll}>
              VIEW ALL PROJECTS <span className={styles.arrow}>&rsaquo;</span>
            </Link>
          </div>
        </div>

        {/* Column 2: Open Source */}
        <div className={styles.megaMenuColumn}>
          <span className={styles.megaMenuHeader}>OPEN SOURCE</span>
          <div className={styles.megaMenuList}>
            {opensourceData.map((os, idx) => (
              <Link href="/opensource" key={idx} className={styles.megaMenuLink}>
                <div className={styles.megaMenuIconWrap} style={{ color: "#3b82f6" }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                </div>
                {os.name}
              </Link>
            ))}
            <Link href="/opensource" className={styles.megaMenuViewAll}>
              VIEW ALL PACKAGES <span className={styles.arrow}>&rsaquo;</span>
            </Link>
          </div>
        </div>

        {/* Column 3: Content */}
        <div className={styles.megaMenuColumn}>
          <span className={styles.megaMenuHeader}>CONTENT</span>
          <div className={styles.megaMenuList}>
            <Link href="/#portfolio" className={styles.megaMenuLink}>
              <div className={styles.megaMenuIconWrap} style={{ color: "#f59e0b" }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
              </div>
              Highlights
            </Link>
            <Link href="/blog" className={styles.megaMenuLink}>
              <div className={styles.megaMenuIconWrap} style={{ color: "#ec4899" }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
              </div>
              Blog
            </Link>
            <Link href="/#last-work" className={styles.megaMenuLink}>
              <div className={styles.megaMenuIconWrap} style={{ color: "#8b5cf6" }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
              </div>
              Last Work
            </Link>
          </div>
        </div>

        {/* Feature Card */}
        <div className={styles.megaMenuFeature}>
          <div className={styles.megaMenuCard}>
            <div className={styles.megaMenuCardGraphic}>
              <img src={latestItem.image} alt={latestItem.title} className={styles.megaMenuCardImg} />
            </div>
            <h4 className={styles.megaMenuCardTitle}>{latestItem.title}</h4>
            <p className={styles.megaMenuCardDesc}>{latestItem.desc}</p>
            <div className={styles.megaMenuCardActions}>
              <Link href={latestItem.link} className={styles.megaMenuBtnSolid}>{latestItem.actionText}</Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

import Link from "next/link";
import Navbar from "@/components/Navbar";
import GlowCard from "@/components/GlowCard";
import {
  getSortedProjects,
  getFeaturedProjects,
} from "@/content/projects";
import styles from "@/app/page.module.css";

export default function ProjectsPage() {
  const allProjects = getSortedProjects();
  const featured = getFeaturedProjects();
  const rest = allProjects.filter((p) => !p.featured);

  return (
    <main className={styles.page}>
      <Navbar backHref="/" backLabel="Home" />

      <section className={styles.pageHero}>
        <div className={styles.pageHeroGlow} aria-hidden="true" />
        <div className={styles.sectionHeader} data-reveal>
          <p>Projects</p>
          <h1 data-split-heading>things I built</h1>
          <span className={styles.pageHeroSub}>
            Competitions, hackathons, tools, and experiments — everything
            that started as an idea and turned into working code.
          </span>
        </div>
      </section>

      <section className={styles.band}>
        <div className={styles.sectionHeader} data-reveal>
          <p>Featured</p>
          <h2 data-split-heading>highlights</h2>
        </div>

        <div className={styles.bentoGrid}>
          {featured.map((project, index) => (
            <GlowCard
              key={project.slug}
              className={`${styles.bentoCard} ${
                index === 0 ? styles.bentoCardWide : ""
              }`}
              data-card
            >
              <div className={styles.bentoImage}>
                <img
                  src={project.image}
                  alt=""
                  loading="lazy"
                  decoding="async"
                />
              </div>
              <div className={styles.bentoContent}>
                <div className={styles.bentoTags}>
                  {project.tags.map((tag) => (
                    <span key={tag} className={styles.tag}>
                      {tag}
                    </span>
                  ))}
                </div>
                <h3>{project.title}</h3>
                <p>{project.description}</p>
                <div className={styles.bentoActions}>
                  {project.repoUrl ? (
                    <a
                      className={styles.projectButton}
                      href={project.repoUrl}
                      target="_blank"
                      rel="noreferrer"
                    >
                      GitHub
                    </a>
                  ) : null}
                  {project.liveUrl ? (
                    <a
                      className={styles.projectButton}
                      href={project.liveUrl}
                      target="_blank"
                      rel="noreferrer"
                    >
                      Live
                    </a>
                  ) : null}
                </div>
              </div>
            </GlowCard>
          ))}
        </div>
      </section>

      {rest.length > 0 ? (
        <section className={styles.band}>
          <div className={styles.sectionHeader} data-reveal>
            <p>All projects</p>
            <h2 data-split-heading>the full list</h2>
          </div>

          <div className={styles.projectGrid}>
            {rest.map((project, index) => (
              <GlowCard
                key={project.slug}
                as="article"
                className={styles.projectCard}
                data-card
              >
                <div>
                  <div className={styles.projectTopline}>
                    <span className={styles.projectNumber}>
                      {String(index + 1).padStart(2, "0")}
                    </span>
                    <p>{project.tags.join(" / ")}</p>
                  </div>
                  <h3>{project.title}</h3>
                  <p>{project.description}</p>
                </div>
                <div className={styles.bentoActions}>
                  {project.repoUrl ? (
                    <a
                      className={styles.projectButton}
                      href={project.repoUrl}
                      target="_blank"
                      rel="noreferrer"
                    >
                      GitHub
                    </a>
                  ) : null}
                </div>
              </GlowCard>
            ))}
          </div>
        </section>
      ) : null}
    </main>
  );
}

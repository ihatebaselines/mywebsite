import { notFound } from "next/navigation";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import { getProject, projects } from "@/content/projects";
import styles from "@/app/page.module.css";

export function generateStaticParams() {
  return projects.map((project) => ({ slug: project.slug }));
}

export default async function ProjectDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const project = getProject(slug);

  if (!project) {
    notFound();
  }

  return (
    <main className={styles.page}>
      <Navbar backHref="/projects" backLabel="Projects" />

      <article className={styles.article}>
        <header className={styles.articleHeader}>
          <p>{project.tags.join(" / ")} — {project.date}</p>
          <h1>{project.title}</h1>
          <span>{project.description}</span>
        </header>

        <div className={styles.articleCover}>
          <img
            className={styles.articleCoverGlow}
            src={project.image}
            alt=""
            loading="eager"
            decoding="async"
          />
          <img
            className={styles.articleCoverImage}
            src={project.image}
            alt=""
            loading="eager"
            decoding="async"
          />
        </div>

        <div className={styles.articleBody}>
          <p>{project.description}</p>
        </div>

        <div className={styles.bentoActions}>
          {project.repoUrl ? (
            <a
              className={styles.repoArticleCard}
              href={project.repoUrl}
              target="_blank"
              rel="noreferrer"
            >
              <span>GitHub repository</span>
              <strong>
                {project.repoUrl.replace("https://github.com/", "")}
              </strong>
              <p>Open the implementation, project files, and latest code.</p>
            </a>
          ) : null}
          {project.liveUrl ? (
            <a
              className={styles.projectButton}
              href={project.liveUrl}
              target="_blank"
              rel="noreferrer"
            >
              View live
            </a>
          ) : null}
        </div>

        <div style={{ marginTop: "24px" }}>
          <div className={styles.bentoTags}>
            {project.tags.map((tag) => (
              <span key={tag} className={styles.tag}>
                {tag}
              </span>
            ))}
          </div>
        </div>
      </article>
    </main>
  );
}

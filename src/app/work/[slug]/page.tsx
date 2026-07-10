import { notFound } from "next/navigation";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import { getWork, workItems } from "@/content/work";
import styles from "@/app/page.module.css";

export function generateStaticParams() {
  return workItems.map((item) => ({ slug: item.slug }));
}

export default async function WorkDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const item = getWork(slug);

  if (!item) {
    notFound();
  }

  return (
    <main className={styles.page}>
      <Navbar backHref="/work" backLabel="Back" />

      <article className={styles.article}>
        <header className={styles.articleHeader}>
          <p>{item.tag} / {item.date}</p>
          <h1>{item.title}</h1>
          <span>{item.summary}</span>
        </header>

        <div className={styles.articleCover}>
          <img
            className={styles.articleCoverGlow}
            src={item.image}
            alt=""
            loading="eager"
            decoding="async"
          />
          <img
            className={styles.articleCoverImage}
            src={item.image}
            alt=""
            loading="eager"
            decoding="async"
          />
        </div>

        <div className={styles.articleBody}>
          {item.body.map((paragraph) => (
            <p key={paragraph}>{paragraph}</p>
          ))}
        </div>

        {item.embedUrl ? (
          <div className={styles.workArticleEmbed}>
            <iframe
              src={item.embedUrl}
              title={`${item.title} live embed`}
              loading="lazy"
            />
          </div>
        ) : null}

        {item.repoUrl ? (
          <a
            className={styles.repoArticleCard}
            href={item.repoUrl}
            target="_blank"
            rel="noreferrer"
          >
            <span>GitHub repository</span>
            <strong>{item.repoUrl.replace("https://github.com/", "")}</strong>
            <p>Open the implementation, project files, and latest code.</p>
          </a>
        ) : null}

        {item.relatedHref ? (
          <Link className={styles.projectButton} href={item.relatedHref}>
            Related post
          </Link>
        ) : null}

        {item.gallery?.length ? (
          <div className={styles.gallery}>
            {item.gallery.map((image) => (
              <img key={image} src={image} alt="" loading="lazy" decoding="async" />
            ))}
          </div>
        ) : null}
      </article>
    </main>
  );
}

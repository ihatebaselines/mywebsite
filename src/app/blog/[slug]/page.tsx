import { notFound } from "next/navigation";
import Link from "next/link";
import { getPost, posts } from "@/content/posts";
import styles from "@/app/page.module.css";

export function generateStaticParams() {
  return posts.map((post) => ({ slug: post.slug }));
}

export default async function BlogPostPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const post = getPost(slug);

  if (!post) {
    notFound();
  }

  return (
    <main className={styles.page}>
      <nav className={styles.nav} aria-label="Main navigation">
        <Link className={styles.mark} href="/">
          ihateb
        </Link>
        <Link className={styles.backLink} href="/#blog">
          Back
        </Link>
      </nav>

      <article className={styles.article}>
        <header className={styles.articleHeader}>
          <p>{post.category} / {post.date}</p>
          <h1>{post.title}</h1>
          <span>{post.excerpt}</span>
        </header>
        <div className={styles.articleCover}>
          <img src={post.cover} alt="" />
        </div>
        <div className={styles.articleBody}>
          {post.body.map((paragraph) => (
            <p key={paragraph}>{paragraph}</p>
          ))}
        </div>
        <div className={styles.gallery}>
          {post.gallery.map((image) => (
            <img key={image} src={image} alt="" />
          ))}
        </div>
      </article>
    </main>
  );
}

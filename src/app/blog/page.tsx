import Link from "next/link";
import BlogSearch from "@/components/BlogSearch";
import { getSortedPosts } from "@/content/posts";
import styles from "@/app/page.module.css";

export default function BlogIndexPage() {
  const sortedPosts = getSortedPosts();

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

      <section className={styles.blogIndex}>
        <div className={styles.sectionHeader}>
          <p>All posts</p>
          <h1>Everything I posted, searchable.</h1>
        </div>
        <BlogSearch posts={sortedPosts} />
      </section>
    </main>
  );
}

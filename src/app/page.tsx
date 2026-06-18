import Link from "next/link";
import DraggableDucks from "@/components/DraggableDucks";
import { getSortedPosts } from "@/content/posts";
import styles from "./page.module.css";

export default function Home() {
  const sortedPosts = getSortedPosts();
  const recentPosts = sortedPosts.slice(0, 4);
  const previewPosts = sortedPosts.slice(0, 6);
  const teaserPosts = sortedPosts.slice(6, 8);
  const hiddenPostCount = Math.max(sortedPosts.length - previewPosts.length, 0);

  return (
    <main className={styles.page}>
      <nav className={styles.nav} aria-label="Main navigation">
        <Link className={styles.mark} href="/">
          ihateb
        </Link>
        <div className={styles.navLinks}>
          <a href="#portfolio">Portfolio</a>
          <a href="#blog">Blog</a>
          <a href="mailto:rusvlad1010@icloud.com">Contact</a>
        </div>
      </nav>

      <section className={styles.hero}>
        <DraggableDucks />
        <div className={styles.heroCopy}>
          <p className={styles.kicker}>you can drag the cats :))))</p>
          <h1>
            welcome
            <span className={styles.sadWrap}>
              {" "}
              <img
                className={styles.sadFace}
                src="/images/sad.webp"
                alt="sad face"
              />
            </span>
          </h1>
          <p>you can check my portofolio here(:</p>

          <div className={styles.heroActions}>
            <a className={styles.rawButton} href="#blog">
              <span>See posts</span>
            </a>
            <a
              className={styles.rawButton}
              href="https://www.linkedin.com/in/vladandreirus"
              target="_blank"
              rel="noreferrer"
            >
              <span>LinkedIn</span>
            </a>
            <a
              className={styles.rawButton}
              href="https://discordapp.com/users/934847546432581682"
              target="_blank"
              rel="noreferrer"
            >
              <span>Discord</span>
            </a>
          </div>

          <div className={styles.aboutMe}>
            <span>About me</span>
            <p>
  Student based in Cluj-Napoca, studying at Colegiul Național &quot;Emil
  Racoviță&quot;. I&apos;m interested in AI, competitive programming, mathematics,
  research, and building projects that mix technical depth with real-world use.
  I&apos;ve been involved in competitions, hackathons, and AI-related projects,
  many of which are documented on my LinkedIn and throughout this website.
</p>
          </div>
        </div>
      </section>

      <section id="portfolio" className={styles.band}>
        <div className={styles.sectionHeader}>
          <p>MOREEE</p>
          <h2>Recent things I have done</h2>
        </div>
        <div className={styles.projectGrid}>
          {recentPosts.map((post, index) => (
            <article className={styles.projectCard} key={post.slug}>
              <div>
                <div className={styles.projectTopline}>
                  <span className={styles.projectNumber}>
                    {String(index + 1).padStart(2, "0")}
                  </span>
                  <p>
                    {post.category} / {post.date}
                  </p>
                </div>
                <h3>{post.title}</h3>
                <p>{post.shortStory}</p>
              </div>
              <Link className={styles.projectButton} href={`/blog/${post.slug}`}>
                Visit blog
              </Link>
            </article>
          ))}
        </div>
      </section>

      <section id="blog" className={styles.band}>
        <div className={styles.sectionHeaderRow}>
          <div className={styles.sectionHeader}>
            <p>Blog</p>
            <h2>Posts, photos and updates from my work.</h2>
          </div>
          <Link className={styles.projectButton} href="/blog">
            Search all
          </Link>
        </div>
        <div className={styles.postGrid}>
          {previewPosts.map((post, index) => (
            <Link
              className={styles.postCard}
              href={`/blog/${post.slug}`}
              key={`${post.slug}-${post.date}-${index}`}
            >
              <div className={styles.postImage}>
                <img src={post.cover} alt="" />
              </div>
              <div>
                <p>
                  {post.category} / {post.date}
                </p>
                <h3>{post.title}</h3>
                <span>{post.excerpt}</span>
              </div>
            </Link>
          ))}
        </div>
        {hiddenPostCount > 0 ? (
          <div className={styles.blogPreviewTail}>
            <div className={styles.tailCards} aria-hidden="true">
              {teaserPosts.map((post, index) => (
                <div
                  className={styles.tailCard}
                  key={`${post.slug}-${post.date}-tail-${index}`}
                >
                  <img src={post.cover} alt="" />
                  <span>{post.title}</span>
                </div>
              ))}
            </div>
            <div className={styles.tailOverlay}>
              <p>{hiddenPostCount} more waiting</p>
              <Link className={styles.projectButton} href="/blog">
                View all posts
              </Link>
            </div>
          </div>
        ) : (
          <div className={styles.blogPreviewTail}>
            <div className={styles.tailOverlay}>
              <p>Want the search view?</p>
              <Link className={styles.projectButton} href="/blog">
                Open all posts
              </Link>
            </div>
          </div>
        )}
      </section>
    </main>
  );
}

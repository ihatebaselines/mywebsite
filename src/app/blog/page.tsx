import Image from "next/image";
import Link from "next/link";
import BlogSearch from "@/components/BlogSearch";
import { getSortedPosts } from "@/content/posts";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Blog — ihatebaselines",
  description: "Random thoughts, experiments, and things learned while building on the internet.",
};

export default function BlogIndexPage() {
  const posts = getSortedPosts();
  const featured = posts[0];
  return (
    <main className="site-main">
      <PageIntro eyebrow="notes from the process · 07" title="blog" description="Random thoughts, experiments, and things learned while building on the internet." aside="same curiosity. different day." />
      {featured ? <section className="section-block" aria-label="Featured post">
        <div className="section-head"><div><span className="section-kicker">featured note</span></div><Link className="text-link" href={`/blog/${featured.slug}`}>Read the post <span aria-hidden="true">→</span></Link></div>
        <article className="blog-featured">
          <Link className="entry-image" href={`/blog/${featured.slug}`}><Image src={featured.cover} alt="" fill sizes="(max-width: 720px) 90vw, 40vw" /></Link>
          <div className="entry-copy"><p className="entry-meta">{featured.category} · {featured.date}</p><h2><Link href={`/blog/${featured.slug}`}>{featured.title}</Link></h2><p>{featured.excerpt}</p><span className="entry-arrow" aria-hidden="true">→</span></div>
        </article>
      </section> : null}
      <hr className="section-divider" />
      <div className="section-head"><div><span className="section-kicker">the archive</span><h2>all posts<span className="title-period">.</span></h2></div></div>
      <BlogSearch posts={posts} />
    </main>
  );
}

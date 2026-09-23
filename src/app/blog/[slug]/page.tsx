import React from "react";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import PhotoGallery from "@/components/PhotoGallery";
import { getPost, posts } from "@/content/posts";

export function generateStaticParams() {
  return posts.map((post) => ({ slug: post.slug }));
}

function renderFormattedParagraph(text: string) {
  const linkRegex = /\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/g;
  const elements: React.ReactNode[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;
  while ((match = linkRegex.exec(text)) !== null) {
    if (match.index > lastIndex) elements.push(text.substring(lastIndex, match.index));
    elements.push(<a key={`${match.index}-${match[2]}`} href={match[2]} target="_blank" rel="noreferrer">{match[1]}</a>);
    lastIndex = linkRegex.lastIndex;
  }
  if (lastIndex < text.length) elements.push(text.substring(lastIndex));
  return elements.length ? elements : text;
}

export default async function BlogPostPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = getPost(slug);
  if (!post) notFound();

  return (
    <main className="site-main">
      <article className="article-layout">
        <Link className="text-link" href="/blog">← Back to the blog</Link>
        <header className="article-header">
          <p className="entry-meta">{post.category} / {post.date}</p>
          <h1>{post.title}</h1>
          <p>{post.excerpt}</p>
        </header>
        {post.cover ? <div className="article-cover"><Image src={post.cover} alt="" width={1400} height={800} priority /></div> : null}
        <div className="article-body">{post.body.map((paragraph, index) => <p key={index}>{renderFormattedParagraph(paragraph)}</p>)}</div>
        {post.links?.length ? <section className="article-resources"><div className="section-head"><div><span className="section-kicker">resources</span><h2>Further reading.</h2></div></div><div className="listing-grid two-col">{post.links.map((link) => <a className="entry-card resource-card" key={link.url} href={link.url} target="_blank" rel="noreferrer"><span className="entry-meta">{link.badge || "EXTERNAL RESOURCE"}</span><h3>{link.title} ↗</h3>{link.description ? <p>{link.description}</p> : null}<small>{link.url.replace(/^https?:\/\//, "").replace(/\/$/, "")}</small></a>)}</div></section> : null}
        {post.gallery?.length ? <PhotoGallery images={post.gallery} title="Event Photos & Showcase" /> : null}
      </article>
    </main>
  );
}

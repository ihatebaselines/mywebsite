import React from "react";
import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import PhotoGallery from "@/components/PhotoGallery";
import ArticleContent from "@/components/ArticleContent";
import { getPost, posts } from "@/content/posts";

export function generateStaticParams() {
  return posts.map((post) => ({ slug: post.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  const post = getPost(slug);
  if (!post) return {};
  const imageUrl = post.cover ? (post.cover.startsWith("http") ? post.cover : `https://ihatebaselines.com${post.cover}`) : "https://ihatebaselines.com/images/ihatebaselines.jpg";
  const desc = post.excerpt || post.shortStory || "Blog post by Vlad Andrei Rus on ihatebaselines.";
  return {
    title: `${post.title} — ihatebaselines.`,
    description: desc,
    openGraph: {
      title: `${post.title} — ihatebaselines.`,
      description: desc,
      url: `https://ihatebaselines.com/blog/${slug}`,
      images: [
        {
          url: imageUrl,
          alt: post.title,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: `${post.title} — ihatebaselines.`,
      description: desc,
      images: [imageUrl],
    },
  };
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
        <ArticleContent body={post.body} />
        {post.links?.length ? <section className="article-resources"><div className="section-head"><div><span className="section-kicker">resources</span><h2>Further reading.</h2></div></div><div className="listing-grid two-col">{post.links.map((link) => <a className="entry-card resource-card" key={link.url} href={link.url} target="_blank" rel="noreferrer"><span className="entry-meta">{link.badge || "EXTERNAL RESOURCE"}</span><h3>{link.title} ↗</h3>{link.description ? <p>{link.description}</p> : null}<small>{link.url.replace(/^https?:\/\//, "").replace(/\/$/, "")}</small></a>)}</div></section> : null}
        {post.gallery?.length ? <PhotoGallery images={post.gallery} title="Event Photos & Showcase" /> : null}
      </article>
    </main>
  );
}

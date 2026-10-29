import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import PhotoGallery from "@/components/PhotoGallery";
import { getWork, workItems } from "@/content/work";

export function generateStaticParams() {
  return workItems.map((item) => ({ slug: item.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  const item = getWork(slug);
  if (!item) return {};
  const imageUrl = item.image ? (item.image.startsWith("http") ? item.image : `https://ihatebaselines.com${item.image}`) : "https://ihatebaselines.com/images/ihatebaselines.jpg";
  return {
    title: `${item.title} — ihatebaselines.`,
    description: item.summary || "Work entry by Vlad Andrei Rus on ihatebaselines.",
    openGraph: {
      title: `${item.title} — ihatebaselines.`,
      description: item.summary,
      url: `https://ihatebaselines.com/work/${slug}`,
      images: [
        {
          url: imageUrl,
          alt: item.title,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: `${item.title} — ihatebaselines.`,
      description: item.summary,
      images: [imageUrl],
    },
  };
}

export default async function WorkDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const item = getWork(slug);
  if (!item) notFound();
  return (
    <main className="site-main"><article className="article-layout">
      <Link className="text-link" href="/work">← Back to work</Link>
      <header className="article-header"><p className="entry-meta">{item.tag} / {item.date}</p><h1>{item.title}</h1><p>{item.summary}</p></header>
      {item.image ? <div className="article-cover"><Image src={item.image} alt="" width={1400} height={800} priority /></div> : null}
      <div className="article-body">{item.body.map((paragraph) => <p key={paragraph}>{paragraph}</p>)}</div>
      {item.embedUrl ? <div className="work-embed"><iframe src={item.embedUrl} title={`${item.title} live embed`} loading="lazy" /></div> : null}
      {item.repoUrl ? <a className="entry-card resource-card" href={item.repoUrl} target="_blank" rel="noreferrer"><span className="entry-meta">GITHUB REPOSITORY</span><h2>{item.repoUrl.replace("https://github.com/", "")} ↗</h2><p>Open the implementation, project files, and latest code.</p></a> : null}
      {item.links?.map((link) => (
        <a key={link.url} className="entry-card resource-card" href={link.url} target="_blank" rel="noreferrer">
          <span className="entry-meta">{link.label.toUpperCase()}</span>
          <h2>{link.url.replace(/^https?:\/\//, "").replace(/\/$/, "")} ↗</h2>
          {link.description ? <p>{link.description}</p> : null}
        </a>
      ))}
      {item.relatedHref ? <p><Link className="button" href={item.relatedHref}>Related post →</Link></p> : null}
      {item.gallery?.length ? <PhotoGallery images={item.gallery} title={`${item.title} Showcase`} /> : null}
    </article></main>
  );
}

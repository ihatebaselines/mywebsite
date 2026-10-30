import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import PhotoGallery from "@/components/PhotoGallery";
import { getProject, projects } from "@/content/projects";

export function generateStaticParams() {
  return projects.map((project) => ({ slug: project.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  const project = getProject(slug);
  if (!project) return {};
  const imageUrl = project.image ? (project.image.startsWith("http") ? project.image : `https://ihatebaselines.com${project.image}`) : "https://ihatebaselines.com/images/ihatebaselines.jpg";
  return {
    title: `${project.title} — ihatebaselines.`,
    description: project.description || "Project by Vlad Andrei Rus on ihatebaselines.",
    openGraph: {
      title: `${project.title} — ihatebaselines.`,
      description: project.description,
      url: `https://ihatebaselines.com/projects/${slug}`,
      images: [
        {
          url: imageUrl,
          alt: project.title,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: `${project.title} — ihatebaselines.`,
      description: project.description,
      images: [imageUrl],
    },
  };
}

export default async function ProjectDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const project = getProject(slug);
  if (!project) notFound();
  return (
    <main className="site-main"><article className="article-layout">
      <Link className="text-link" href="/projects">← Back to projects</Link>
      <header className="article-header"><p className="entry-meta">{project.tags.join(" / ")} — {project.date}</p><h1>{project.title}</h1><p>{project.description}</p></header>
      {project.image ? <div className="article-cover"><Image src={project.image} alt="" width={1400} height={800} priority /></div> : null}
      <div className="article-body"><p>{project.description}</p></div>
      {project.gallery && project.gallery.length > 1 ? <PhotoGallery images={project.gallery} title={`${project.title} Gallery`} /> : null}
      <div className="button-row">
        {project.repoUrl ? <a className="button" href={project.repoUrl} target="_blank" rel="noreferrer">GitHub repository ↗</a> : null}
        {project.liveUrl ? (
          project.liveUrl.startsWith("/") ? (
            <Link className="button button-primary" href={project.liveUrl}>Read architecture deep-dive →</Link>
          ) : (
            <a className="button button-primary" href={project.liveUrl} target="_blank" rel="noreferrer">View live ↗</a>
          )
        ) : null}
      </div>
      <div className="tag-list project-detail-tags">{project.tags.map((tag) => <span className="tag" key={tag}>{tag}</span>)}</div>
    </article></main>
  );
}

import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import PhotoGallery from "@/components/PhotoGallery";
import { getProject, projects } from "@/content/projects";

export function generateStaticParams() {
  return projects.map((project) => ({ slug: project.slug }));
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
      <div className="button-row">{project.repoUrl ? <a className="button" href={project.repoUrl} target="_blank" rel="noreferrer">GitHub repository ↗</a> : null}{project.liveUrl ? <a className="button button-primary" href={project.liveUrl} target="_blank" rel="noreferrer">View live ↗</a> : null}</div>
      <div className="tag-list project-detail-tags">{project.tags.map((tag) => <span className="tag" key={tag}>{tag}</span>)}</div>
    </article></main>
  );
}

import Link from "next/link";
import { getFeaturedProjects, getSortedProjects } from "@/content/projects";
import { EntryCard, PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Projects — ihatebaselines",
  description: "A collection of projects, experiments, and small ideas built with curiosity.",
};

export default function ProjectsPage() {
  const all = getSortedProjects();
  const featured = getFeaturedProjects();
  return (
    <main className="site-main">
      <PageIntro eyebrow="things i’ve made · 03" title="things I built" description="A collection of projects, experiments, and small ideas built with curiosity." aside="same curiosity. different things." />
      {featured.length > 0 ? <section className="listing-grid" aria-label="Featured projects">
        {featured.slice(0, 2).map((project) => <EntryCard key={project.slug} href={`/projects/${project.slug}`} title={project.title} description={project.description} meta={`FEATURED · ${project.date}`} image={project.image} tags={project.tags} featured />)}
      </section> : null}
      {all.length > featured.length ? <>
        <hr className="section-divider" />
        <div className="section-head"><div><span className="section-kicker">the full list</span><h2>more projects<span className="title-period">.</span></h2></div></div>
        <section className="listing-grid three-col" aria-label="All projects">
          {all.filter((project) => !project.featured).map((project) => <EntryCard key={project.slug} href={`/projects/${project.slug}`} title={project.title} description={project.description} meta={project.date} image={project.image} tags={project.tags} />)}
        </section>
      </> : null}
      <div className="section-block"><Link className="text-link" href="/opensource">More code in the open <span aria-hidden="true">→</span></Link></div>
    </main>
  );
}

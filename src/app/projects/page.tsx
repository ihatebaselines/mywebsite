import Image from "next/image";
import { getFeaturedProjects, getSortedProjects } from "@/content/projects";
import { getSortedOpenSource } from "@/content/opensource";
import { EntryCard, ExternalEntryCard, PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Projects — ihatebaselines",
  description: "A collection of projects, open source code, and experiments built with curiosity.",
};

export default function ProjectsPage() {
  const all = getSortedProjects();
  const featured = getFeaturedProjects();
  const openSourceItems = getSortedOpenSource();

  return (
    <main className="site-main">
      <PageIntro
        eyebrow="things i’ve made"
        title="projects"
        description="A collection of models, open-source libraries, and experiments built with curiosity."
      />

      {featured.length > 0 ? (
        <section className="listing-grid" aria-label="Featured projects">
          {featured.map((project, index) => (
            <EntryCard
              key={project.slug}
              href={`/projects/${project.slug}`}
              title={project.title}
              description={project.description}
              meta={`FEATURED · ${project.date}`}
              image={project.image}
              tags={project.tags}
              featured={index === 0}
            />
          ))}
        </section>
      ) : null}

      {all.length > featured.length ? (
        <>
          <hr className="section-divider" />
          <div className="section-head">
            <div>
              <span className="section-kicker">the full list</span>
              <h2>more projects<span className="title-period">.</span></h2>
            </div>
          </div>
          <section className="listing-grid three-col" aria-label="All projects">
            {all
              .filter((project) => !project.featured)
              .map((project) => (
                <EntryCard
                  key={project.slug}
                  href={`/projects/${project.slug}`}
                  title={project.title}
                  description={project.description}
                  meta={project.date}
                  image={project.image}
                  tags={project.tags}
                />
              ))}
          </section>
        </>
      ) : null}

      {openSourceItems.length > 0 ? (
        <section className="section-block" id="opensource">
          <hr className="section-divider" />
          <div className="section-head">
            <div>
              <span className="section-kicker">code in the open</span>
              <h2>open source<span className="title-period">.</span></h2>
              <p>Tools, libraries, and repositories built for the public.</p>
            </div>
            <a
              className="text-link"
              href="https://github.com/ihatebaselines"
              target="_blank"
              rel="noreferrer"
            >
              View all on GitHub <span aria-hidden="true">→</span>
            </a>
          </div>
          <div className="listing-grid two-col">
            {openSourceItems.map((item) => (
              <ExternalEntryCard
                key={item.slug}
                href={item.repoUrl}
                title={item.name}
                description={item.description}
                meta={item.language}
                image={item.image}
                tags={item.topics}
              />
            ))}
          </div>
        </section>
      ) : null}

      <section className="section-block">
        <hr className="section-divider" />
        <div className="illustrated-end">
          <div>
            <h2>Want to build on it?</h2>
            <p className="page-description">
              Everything listed here is public. Explore the repositories, open an issue, or fork something and make it your own.
            </p>
            <a
              className="button button-primary"
              href="https://github.com/ihatebaselines"
              target="_blank"
              rel="noreferrer"
            >
              View GitHub profile <span aria-hidden="true">↗</span>
            </a>
          </div>
          <figure>
            <Image
              src="/images/pixel-cat-tv.jpg"
              alt="Pixel art Siamese cat relaxing on a red sofa"
              fill
              sizes="(max-width: 720px) 90vw, 28vw"
            />
          </figure>
        </div>
      </section>
    </main>
  );
}

import Link from "next/link";
import { EntryCard } from "@/components/SiteCards";
import { getFeaturedProjects, projects } from "@/content/projects";
import { getSortedPosts, posts } from "@/content/posts";
import { getSortedWork, workItems } from "@/content/work";
import DrunkTitle from "@/components/home/DrunkTitle";
import RandomHeroVisual from "@/components/home/RandomHeroVisual";

const destinations = [
  { number: "01", label: "work", href: "/work" },
  { number: "02", label: "blog", href: "/blog" },
  { number: "03", label: "projects", href: "/projects" },
  { number: "04", label: "licenses", href: "/licenses" },
  { number: "05", label: "updates", href: "/changelog" },
];

export default function Home() {
  const sortedPosts = getSortedPosts();
  const featuredProjects = getFeaturedProjects();
  const competitions = getSortedWork().filter((item) => /competition|hackathon/i.test(item.tag));
  const competitionCount = competitions.length;

  return (
    <main className="site-main home-minimal-main">
      {/* First Viewport: Exact Minimalist Hero */}
      <section className="hero-minimal" aria-labelledby="home-title">
        <div className="hero-minimal-center">
          <div className="hero-minimal-copy">
            <DrunkTitle />
            <p className="hero-minimal-desc">
              student developer building AI, open source, and things that start at zero.
            </p>
            <div>
              <Link className="hero-minimal-cta" href="/work">
                view my work <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
          <RandomHeroVisual />
        </div>

        <div className="hero-minimal-bottom">
          <div className="hero-strip" aria-label="Featured projects">
            <Link href="/projects/swift" className="strip-item">
              <span className="strip-num">01</span>
              <span className="strip-label">swiftfox</span>
            </Link>
            <span className="strip-sep" aria-hidden="true">|</span>
            <Link href="/projects/socrate-main-model" className="strip-item">
              <span className="strip-num">02</span>
              <span className="strip-label">socratex</span>
            </Link>
            <span className="strip-sep" aria-hidden="true">|</span>
            <Link href="/projects/skillab-radar" className="strip-item">
              <span className="strip-num">03</span>
              <span className="strip-label">skillab radar</span>
            </Link>
          </div>
          <p className="hero-location">cluj-napoca &middot; 2026</p>
        </div>
      </section>

      {/* 01 / About */}
      <section className="min-section" aria-labelledby="min-about-title">
        <div className="min-section-head">
          <span className="min-kicker">01 / about</span>
          <Link className="min-link" href="/about">
            more about me <span aria-hidden="true">→</span>
          </Link>
        </div>
        <div className="min-about-block">
          <h2 id="min-about-title">
            hi, i’m vlad<span className="title-period">.</span>
          </h2>
          <p>
            I’m a student based in Cluj-Napoca, studying at Colegiul Național “Emil Racoviță”. I’m
            interested in AI architectures, competitive programming, mathematics, research, and
            building things from zero.
          </p>
          <div className="min-meta-bar">
            <span>
              currently {"<->"} <strong>learning in public &middot; building from zero</strong>
            </span>
            <span>
              {workItems.length} work &middot; {competitionCount} competitions &middot;{" "}
              {projects.length} projects &middot; {posts.length} notes
            </span>
          </div>
        </div>
      </section>

      {/* 02 / Recent Notes & Small Blogs */}
      <section className="min-section" aria-labelledby="min-blogs-title">
        <div className="min-section-head">
          <div>
            <span className="min-kicker" id="min-blogs-title">
              02 / recent notes &amp; small blogs
            </span>
          </div>
          <Link className="min-link" href="/blog">
            view all blogs ({posts.length}) <span aria-hidden="true">→</span>
          </Link>
        </div>
        <div className="listing-grid three-col home-blog-grid">
          {sortedPosts.slice(0, 3).map((post) => (
            <EntryCard
              key={post.slug}
              href={`/blog/${post.slug}`}
              title={post.title}
              description={post.excerpt}
              meta={`${post.category} <-> ${post.date}`}
              image={post.cover}
            />
          ))}
        </div>
      </section>

      {/* 03 / Projects */}
      <section className="min-section" aria-labelledby="min-projects-title">
        <div className="min-section-head">
          <span className="min-kicker" id="min-projects-title">
            03 / projects
          </span>
          <Link className="min-link" href="/projects">
            see all projects <span aria-hidden="true">→</span>
          </Link>
        </div>
        <div className="min-list">
          {featuredProjects.map((project, idx) => (
            <Link key={project.slug} href={`/projects/${project.slug}`} className="min-row">
              <span className="min-row-num">{String(idx + 1).padStart(2, "0")}</span>
              <div className="min-row-main">
                <h3>{project.title.toLowerCase()}</h3>
                <p>{project.description}</p>
              </div>
              <div className="min-row-meta">
                <span>{project.tags.slice(0, 2).join(" · ").toLowerCase()}</span>
                <span className="min-row-arrow" aria-hidden="true">→</span>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* 04 / Competitions & Hackathons */}
      <section className="min-section" aria-labelledby="min-comp-title">
        <div className="min-section-head">
          <span className="min-kicker" id="min-comp-title">
            04 / competitions &amp; hackathons
          </span>
          <Link className="min-link" href="/awards">
            all results <span aria-hidden="true">→</span>
          </Link>
        </div>
        <div className="min-list">
          {competitions.slice(0, 5).map((item, idx) => (
            <Link key={item.slug} href={`/work/${item.slug}`} className="min-row">
              <span className="min-row-num">{String(idx + 1).padStart(2, "0")}</span>
              <div className="min-row-main">
                <h3>
                  {item.title}{" "}
                  {item.result ? <em className="min-row-badge">{item.result}</em> : null}
                </h3>
                <p>{item.summary}</p>
              </div>
              <div className="min-row-meta">
                <span>{item.date}</span>
                <span className="min-row-arrow" aria-hidden="true">→</span>
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* 05 / Explore & Say Hi */}
      <section className="min-section" aria-labelledby="min-contact-title">
        <div className="min-section-head">
          <span className="min-kicker">05 / directory &amp; contact</span>
        </div>
        <div className="hero-strip min-explore-strip" aria-label="Site directory">
          {destinations.map((item, i) => (
            <span key={item.number} className="strip-wrap">
              <Link href={item.href} className="strip-item">
                <span className="strip-num">{item.number}</span>
                <span className="strip-label">{item.label}</span>
              </Link>
              {i < destinations.length - 1 ? (
                <span className="strip-sep" aria-hidden="true">|</span>
              ) : null}
            </span>
          ))}
        </div>

        <div className="min-contact-block">
          <div>
            <h2 id="min-contact-title">
              good things start with a hello<span className="title-period">.</span>
            </h2>
            <p>Have a project, question, or just want to talk? My inbox is open.</p>
          </div>
          <div className="min-contact-actions">
            <a className="hero-minimal-cta" href="mailto:rusvlad1010@icloud.com">
              rusvlad1010@icloud.com <span aria-hidden="true">→</span>
            </a>
            <div className="min-socials">
              <a href="https://github.com/ihatebaselines" target="_blank" rel="noreferrer">
                github ↗
              </a>
              <a href="https://www.linkedin.com/in/vladandreirus" target="_blank" rel="noreferrer">
                linkedin ↗
              </a>
              <a href="https://www.instagram.com/_rusuuu__" target="_blank" rel="noreferrer">
                instagram ↗
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}

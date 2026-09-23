import Image from "next/image";
import Link from "next/link";
import { EntryCard, PageIntro } from "@/components/SiteCards";
import { getFeaturedProjects, projects } from "@/content/projects";
import { getSortedPosts, posts } from "@/content/posts";
import { getSortedWork, workItems } from "@/content/work";

const destinations = [
  { number: "01", label: "Work", copy: "things i’ve built and shipped.", href: "/work" },
  { number: "02", label: "Blog", copy: "thoughts, notes, and experiments.", href: "/blog" },
  { number: "03", label: "Projects", copy: "small ideas, bigger possibilities.", href: "/projects" },
  { number: "04", label: "Open Source", copy: "code for a more open internet.", href: "/opensource" },
  { number: "05", label: "Licenses", copy: "the tools behind this little corner.", href: "/licenses" },
  { number: "06", label: "Updates", copy: "what changed, and what’s next.", href: "/changelog" },
];

export default function Home() {
  const sortedPosts = getSortedPosts();
  const featuredProjects = getFeaturedProjects();
  const competitions = getSortedWork().filter((item) => /competition|hackathon/i.test(item.tag));
  const competitionCount = competitions.length;

  return (
    <main className="site-main home-main">
      <section className="home-hero" aria-labelledby="home-title">
        <div className="hero-copy">
          <p className="eyebrow">a student developer, still figuring it out</p>
          <h1 className="home-title" id="home-title"><span>i hate</span><span>baselines<span className="title-period">.</span></span></h1>
          <p className="hero-description">student developer building AI, open source, and things that start at zero.</p>
          <div className="button-row">
            <Link className="button button-primary" href="/work">View my work <span aria-hidden="true">→</span></Link>
            <Link className="button" href="/blog">Read the blog</Link>
            <Link className="button" href="/projects">See projects</Link>
          </div>
          <p className="hero-note">same curiosity. different day.</p>
          <div className="hero-stats" aria-label="Portfolio at a glance">
            <div className="hero-stat"><strong>{workItems.length}</strong><span>work entries</span></div>
            <div className="hero-stat"><strong>{competitionCount}</strong><span>competitions</span></div>
            <div className="hero-stat"><strong>{projects.length}</strong><span>projects</span></div>
            <div className="hero-stat"><strong>{posts.length}</strong><span>notes & stories</span></div>
          </div>
        </div>
        <figure className="hero-visual">
          <Image src="/images/cat-ocean-hero.png" alt="A very relaxed Siamese cat floating on the ocean with a drink and a bottle" fill priority sizes="(max-width: 720px) 100vw, 55vw" />
        </figure>
      </section>

      <section className="home-section home-readme" aria-label="A little about me" data-reveal>
        <div className="readme-copy">
          <span className="section-kicker">01 / README.md</span>
          <h2>hi, i’m vlad<span className="title-period">.</span></h2>
          <p>I’m a student based in Cluj-Napoca, studying at Colegiul Național “Emil Racoviță”. I’m interested in AI architectures, competitive programming, mathematics, research, and building things from zero.</p>
          <Link className="text-link" href="/about">A little more about me <span aria-hidden="true">→</span></Link>
        </div>
        <article className="readme-box" aria-label="README file">
          <div className="readme-box-head"><span className="window-dots" aria-hidden="true">● ● ●</span><span>README.md</span><span className="readme-rank">student / Cluj-Napoca</span></div>
          <div className="readme-box-body"><p><strong>Student developer</strong>, interested in technology, design, and the intersection of all three. I like building things, exploring new ideas, and documenting the journey along the way.</p><div className="readme-status"><span>currently</span><strong>learning in public · building from zero</strong></div></div>
        </article>
      </section>

      <section className="home-section" aria-labelledby="home-projects-title" data-reveal>
        <div className="section-head"><div><span className="section-kicker">02 / projects</span><h2 id="home-projects-title">some things<span className="title-period">.</span></h2><p>projects, experiments, and ideas that somehow worked.</p></div><Link className="text-link" href="/projects">See all projects <span aria-hidden="true">→</span></Link></div>
        <div className="listing-grid home-project-grid">
          {featuredProjects.map((project) => <EntryCard key={project.slug} href={`/projects/${project.slug}`} title={project.title} description={project.description} meta={`PROJECT · ${project.date}`} image={project.image} tags={project.tags} />)}
        </div>
      </section>

      <section className="home-section" aria-labelledby="home-highlights-title" data-reveal>
        <div className="section-head"><div><span className="section-kicker">03 / highlights</span><h2 id="home-highlights-title">small wins. big motivation.</h2></div></div>
        <div className="highlight-grid">
          {competitions.slice(0, 4).map((item) => <Link className="highlight-card" href={`/work/${item.slug}`} key={item.slug}><span className="highlight-mark" aria-hidden="true">✳</span><span className="highlight-result">{item.result ?? "Featured"}</span><strong>{item.title}</strong><small>{item.tag} · {item.date}</small></Link>)}
        </div>
      </section>

      <section className="home-section" aria-labelledby="home-competitions-title" data-reveal>
        <div className="section-head"><div><span className="section-kicker">04 / competitions</span><h2 id="home-competitions-title">recent competitions / hackathons</h2><p>small steps, bigger things.</p></div><Link className="text-link" href="/awards">All results <span aria-hidden="true">→</span></Link></div>
        <div className="listing-grid three-col">
          {competitions.slice(0, 3).map((item) => <EntryCard key={item.slug} href={`/work/${item.slug}`} title={item.title} description={item.summary} meta={`${item.result ?? item.tag} · ${item.date}`} image={item.image} tags={[item.tag]} />)}
        </div>
      </section>

      <section className="home-section" aria-labelledby="home-blog-title" data-reveal>
        <div className="section-head"><div><span className="section-kicker">05 / lately</span><h2 id="home-blog-title">recently<span className="title-period">.</span></h2><p>latest notes, stories, and things worth keeping.</p></div><Link className="text-link" href="/blog">View all posts <span aria-hidden="true">→</span></Link></div>
        <div className="listing-grid three-col home-blog-grid">
          {sortedPosts.slice(0, 3).map((post) => <EntryCard key={post.slug} href={`/blog/${post.slug}`} title={post.title} description={post.excerpt} meta={`${post.category} · ${post.date}`} image={post.cover} />)}
        </div>
      </section>

      <section className="home-explore home-section" aria-labelledby="explore-heading" data-reveal>
        <div className="section-head"><div><span className="section-kicker">06 / explore</span><h2 id="explore-heading">find your way around<span className="title-period">.</span></h2><p>everything else, all in one place.</p></div></div>
        <div className="explore-grid">
          {destinations.map((item) => <Link className="explore-card" href={item.href} key={item.number}><span className="explore-number">{item.number}</span><span><h3>{item.label}</h3><p>{item.copy}</p></span><span className="explore-arrow" aria-hidden="true">↗</span></Link>)}
        </div>
      </section>

      <section className="home-contact home-section" aria-labelledby="home-contact-title" data-reveal>
        <div className="contact-panel">
          <div><small>07 / say hi</small><h2 id="home-contact-title">good things start with a hello<span className="title-period">.</span></h2><p>Have a project, question, or just want to talk? My inbox is open.</p></div>
          <div className="home-contact-links">
            <a className="button button-primary" href="mailto:rusvlad1010@icloud.com">Email me <span aria-hidden="true">→</span></a>
            <div className="home-contact-socials">
              <a href="https://github.com/ihatebaselines" target="_blank" rel="noreferrer">GitHub ↗</a>
              <a href="https://www.linkedin.com/in/vladandreirus" target="_blank" rel="noreferrer">LinkedIn ↗</a>
              <a href="mailto:rusvlad1010@icloud.com">Email ↗</a>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}

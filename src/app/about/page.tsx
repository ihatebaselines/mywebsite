import Link from "next/link";
import { workItems } from "@/content/work";
import { projects } from "@/content/projects";
import { posts } from "@/content/posts";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "About — ihatebaselines",
  description: "A little more about the student developer behind ihatebaselines.",
};

export default function AboutPage() {
  return (
    <main className="site-main">
      <PageIntro eyebrow="a quick introduction · readme.md" title="readme" description="A student developer building AI, open source, and a better internet." aside="same curiosity. different day." />
      <section className="readme-layout">
        <div className="readme-copy">
          <span className="section-kicker">hi, i’m vlad</span>
          <h2>learning by making things.</h2>
          <p>I’m a student based in Cluj-Napoca, studying at Colegiul Național “Emil Racoviță”. I’m interested in AI architectures, competitive programming, mathematics, research, and building things from zero.</p>
          <p>I like learning in public, sharing what I build, and seeing where curiosity leads. This site is a small record of that process.</p>
          <div className="button-row"><Link className="button button-primary" href="/work">View my work <span aria-hidden="true">→</span></Link><Link className="button" href="/contact">Say hi</Link></div>
        </div>
        <article className="readme-box" aria-label="README file">
          <div className="readme-box-head"><span aria-hidden="true">● ● ●</span><span>README.md</span></div>
          <div className="readme-box-body">
            <h2># ihatebaselines</h2>
            <p>student developer building AI, open source,<br />and things that start at zero.</p>
            <h3>## currently</h3>
            <ul><li>exploring AI and what’s possible</li><li>building open-source projects</li><li>learning in public</li><li>trying to be a little more useful each day</li></ul>
            <h3>## philosophy</h3>
            <p>small ideas, bigger possibilities.<span className="title-period"> ▍</span></p>
          </div>
        </article>
      </section>
      <section className="readme-stats" aria-label="Site content counts">
        <div className="readme-stat"><strong>{workItems.length}</strong><span>work entries</span></div>
        <div className="readme-stat"><strong>{projects.length}</strong><span>listed projects</span></div>
        <div className="readme-stat"><strong>{posts.length}</strong><span>published posts</span></div>
        <div className="readme-stat"><strong>∞</strong><span>things to learn</span></div>
      </section>
    </main>
  );
}

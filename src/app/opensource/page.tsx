import { getSortedOpenSource } from "@/content/opensource";
import { ExternalEntryCard, PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Open Source — ihatebaselines",
  description: "Open-source repositories, tools, and experiments from ihatebaselines.",
};

export default function OpenSourcePage() {
  const items = getSortedOpenSource();
  const featured = items[0];
  return (
    <main className="site-main">
      <PageIntro eyebrow="code in the open · 04" title="code in the open" description="Tools, templates, and experiments for a more open internet. Small ideas, real code." aside="open source software. fewer barriers. more builders." />
      <section className="section-block" aria-label="Featured repository">
        <div className="section-head"><div><span className="section-kicker">featured repository</span></div>{featured ? <a className="text-link" href="https://github.com/ihatebaselines" target="_blank" rel="noreferrer">View all on GitHub <span aria-hidden="true">→</span></a> : null}</div>
        {featured ? <a className="featured-repo" href={featured.repoUrl} target="_blank" rel="noreferrer">
          <span className="repo-mark" aria-hidden="true">⌘</span>
          <span><h2>{featured.name}</h2><p>{featured.description}</p><span className="tag-list">{featured.topics.map((topic) => <span className="tag" key={topic}>{topic}</span>)}</span></span>
          <span className="repo-stats">{featured.language}<br />Browse the repository ↗</span>
        </a> : <p className="empty-state">No repositories are listed here yet.</p>}
      </section>
      {items.length > 1 ? <section className="section-block">
        <hr className="section-divider" />
        <div className="section-head"><div><span className="section-kicker">all repositories</span></div></div>
        <div className="listing-grid three-col">{items.slice(1).map((item) => <ExternalEntryCard key={item.slug} href={item.repoUrl} title={item.name} description={item.description} meta={item.language} tags={item.topics} />)}</div>
      </section> : null}
      <section className="section-block"><hr className="section-divider" /><h2>Want to build on it?</h2><p className="page-description">Everything listed here is public. Explore the repositories, open an issue, or fork something and make it your own.</p><a className="button button-primary" href="https://github.com/ihatebaselines" target="_blank" rel="noreferrer">View GitHub profile <span aria-hidden="true">↗</span></a></section>
    </main>
  );
}

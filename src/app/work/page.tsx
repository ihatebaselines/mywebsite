import { getSortedWork } from "@/content/work";
import { EntryCard, PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Work — ihatebaselines",
  description: "Projects, competitions, and things I’ve built and shipped.",
};

export default function WorkPage() {
  const items = getSortedWork();
  return (
    <main className="site-main">
      <PageIntro eyebrow="selected work · 01" title="some things" description="Projects, competitions, experiments, and ideas I’ve worked on. Small things, bigger possibilities." aside="build in public. learn by doing. keep going." />
      <section className="listing-grid" aria-label="Work and competition entries">
        {items.map((item, index) => <EntryCard key={item.slug} href={`/work/${item.slug}`} title={item.title} description={item.summary} meta={`${item.tag} · ${item.date}`} image={item.image} featured={index === 0} />)}
      </section>
      <div className="section-block"><a className="text-link" href="/awards">A few competition details <span aria-hidden="true">→</span></a></div>
    </main>
  );
}

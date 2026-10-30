import Link from "next/link";
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
      <PageIntro
        eyebrow="selected work & competitions"
        title="work"
        description="Projects, competitions, experiments, and ideas I’ve worked on."
      />
      <section className="listing-grid" aria-label="Work and competition entries">
        {items.map((item) => (
          <EntryCard
            key={item.slug}
            href={`/work/${item.slug}`}
            title={item.title}
            description={item.summary}
            meta={`${item.tag} · ${item.date}`}
            image={item.image}
          />
        ))}
      </section>
      <div className="section-block">
        <Link className="text-link" href="/awards">
          A few competition details & awards <span aria-hidden="true">→</span>
        </Link>
      </div>
    </main>
  );
}

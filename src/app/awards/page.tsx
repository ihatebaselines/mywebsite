import { workItems } from "@/content/work";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Competitions & Hackathons — ihatebaselines",
  description: "Competition results, hackathons, and what I learned along the way.",
};

const results: Record<string, string> = {
  "ccc-2026": "14th + 31st",
  "rosdc-2026": "Operations",
  "algorithms-to-neurons": "1st + 9th",
  "rise-final": "2nd",
  skillab: "1st",
  nitronlp: "3rd",
  "roai-selection": "Qualifier",
  ccc: "4th + 12th",
};

export default function AwardsPage() {
  const entries = workItems.filter((item) => /competition|hackathon|programming|nlp/i.test(item.tag));
  return (
    <main className="site-main">
      <PageIntro
        eyebrow="competitions & hackathons"
        title="awards"
        description="Competition results, benchmarks, and what I learned along the way."
      />
      <aside className="competition-note"><h2>why competitions?</h2><p>Hackathons push me to learn faster, ship things, and meet amazing people. Even when it’s a weekend project, it’s a chance to try something new and grow.</p></aside>
      <section className="competition-list section-block" aria-label="Competition results">
        {entries.map((item) => <a className="competition-row" href={`/work/${item.slug}`} key={item.slug}>
          <span className="competition-place"><strong>{results[item.slug] ?? "—"}</strong><span>{results[item.slug] ? "result" : "entry"}</span></span>
          <span><h2>{item.title}</h2><p>{item.summary}</p><span className="tag-list"><span className="tag">{item.tag}</span></span></span>
          <span className="competition-date">{item.date}　→</span>
        </a>)}
      </section>
    </main>
  );
}

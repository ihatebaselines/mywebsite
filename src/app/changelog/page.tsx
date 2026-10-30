import ChangelogTimeline from "@/components/ChangelogTimeline";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Updates — ihatebaselines",
  description: "Features, improvements, experiments, and milestones from ihatebaselines.",
};

export default function ChangelogPage() {
  return (
    <main className="site-main">
      <PageIntro
        eyebrow="living log"
        title="updates"
        description="Features, improvements, and milestones from the ihatebaselines project."
      />
      <ChangelogTimeline />
    </main>
  );
}

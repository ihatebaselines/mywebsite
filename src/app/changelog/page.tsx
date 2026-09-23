import ChangelogTimeline from "@/components/ChangelogTimeline";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Updates — ihatebaselines",
  description: "Features, improvements, experiments, and milestones from ihatebaselines.",
};

export default function ChangelogPage() {
  return <main className="site-main"><PageIntro eyebrow="a small, living log · 09" title="updates, versions and milestones" description="Features, improvements, and experiments from the ihatebaselines project." aside="same curiosity. different day." /><ChangelogTimeline /></main>;
}

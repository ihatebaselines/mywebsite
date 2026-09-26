import Image from "next/image";
import ChangelogTimeline from "@/components/ChangelogTimeline";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Updates — ihatebaselines",
  description: "Features, improvements, experiments, and milestones from ihatebaselines.",
};

export default function ChangelogPage() {
  return <main className="site-main"><PageIntro eyebrow="a small, living log · 09" title="updates, versions and milestones" description="Features, improvements, and experiments from the ihatebaselines project." illustration={{ src: "/images/tilcayo-ship-first.png", alt: "Tilcayo cat in a shipping box: ship first, polish later" }} /><ChangelogTimeline /><figure className="end-sticker"><Image src="/images/tilcayo-refresh-repeat.png" alt="Tilcayo cat with a refresh arrow: refresh, regret, repeat" fill sizes="(max-width: 720px) 70vw, 24vw" /></figure></main>;
}

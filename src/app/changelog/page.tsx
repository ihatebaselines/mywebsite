import Image from "next/image";
import ChangelogTimeline from "@/components/ChangelogTimeline";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Updates — ihatebaselines",
  description: "Features, improvements, experiments, and milestones from ihatebaselines.",
};

export default function ChangelogPage() {
  return <main className="site-main"><PageIntro eyebrow="a small, living log · 09" title="updates, versions and milestones" description="Features, improvements, and experiments from the ihatebaselines project." illustration={{ src: "/images/pixel-cat-tv.jpg", alt: "Pixel art Siamese cat relaxing on a red sofa" }} /><ChangelogTimeline /><figure className="end-sticker"><Image src="/images/pixel-cat-hero.jpg" alt="Pixel art Siamese cat yelling" fill sizes="(max-width: 720px) 70vw, 24vw" /></figure></main>;
}

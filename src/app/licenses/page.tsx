import type { Metadata } from "next";
import LicensesClient, { LicenseItem } from "./LicensesClient";
import { PageIntro } from "@/components/SiteCards";
import rawLicensesData from "@/content/licensesData.json";

export const metadata: Metadata = {
  title: "Licenses & Attributions — ihatebaselines",
  description:
    "Comprehensive directory of open-source libraries, frameworks, tools, and typefaces powering ihatebaselines.com.",
};

export default function LicensesPage() {
  const licensesData = rawLicensesData as LicenseItem[];

  return <main className="site-main"><PageIntro eyebrow="open source attributions · 05" title="open source licenses" description="The tools and libraries that power this site. Built by an amazing open-source community." illustration={{ src: "/images/tilcayo-move-it.png", alt: "Tilcayo cat moving a giant cursor: move it -2px" }} /><LicensesClient initialLicenses={licensesData} /></main>;
}

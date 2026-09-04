import type { Metadata } from "next";
import Navbar from "@/components/Navbar";
import LicensesClient, { LicenseItem } from "./LicensesClient";
import rawLicensesData from "@/content/licensesData.json";

export const metadata: Metadata = {
  title: "Licenses & Attributions — ihatebaselines",
  description:
    "Comprehensive directory of open-source libraries, frameworks, tools, and typefaces powering ihatebaselines.com.",
};

export default function LicensesPage() {
  const licensesData = rawLicensesData as LicenseItem[];

  return (
    <>
      <Navbar backHref="/" backLabel="Home" />
      <LicensesClient initialLicenses={licensesData} />
    </>
  );
}

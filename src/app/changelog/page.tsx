import Navbar from "@/components/Navbar";
import ChangelogTimeline from "@/components/ChangelogTimeline";
import styles from "@/app/page.module.css";

export const metadata = {
  title: "Changelog & Updates — vlad andrei",
  description: "Chronological evolution, competition results, and project update log.",
};

export default function ChangelogPage() {
  return (
    <main className={styles.page}>
      <Navbar backHref="/" backLabel="Back to Home" />

      <section className={styles.blogIndex}>
        <div className={styles.sectionHeader}>
          <p>Changelog & Evolution</p>
          <h1>Updates, versions and milestones.</h1>
        </div>

        <ChangelogTimeline />
      </section>
    </main>
  );
}

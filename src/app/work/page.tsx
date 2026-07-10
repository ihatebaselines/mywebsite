import Navbar from "@/components/Navbar";
import RecentWork from "@/components/RecentWork";
import { getSortedWork } from "@/content/work";
import styles from "@/app/page.module.css";

export default function WorkPage() {
  const work = getSortedWork();

  return (
    <main className={styles.page}>
      <Navbar backHref="/#last-work" backLabel="Back" />

      <section className={styles.blogIndex}>
        <div className={styles.sectionHeader}>
          <p>See all work</p>
          <h1>Build logs, experiments, live embeds and project notes.</h1>
        </div>
        <RecentWork items={work} showAll />
      </section>
    </main>
  );
}

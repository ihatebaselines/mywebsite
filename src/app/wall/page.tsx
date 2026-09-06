import Navbar from "@/components/Navbar";
import styles from "@/app/page.module.css";

export const metadata = {
  title: "TheWall — vlad andrei",
  description: "Permanent infinite collaborative whiteboard and guestbook with live synchronization.",
};

export default function WallPage() {
  return (
    <main className={styles.page}>
      <Navbar backHref="/" backLabel="Back to Home" />
      <section className={styles.pageHero}>
        <div className={styles.sectionHeader} data-reveal>
          <p>TheWall</p>
          <h1>temporarily offline.</h1>
          <span className={styles.pageHeroSub}>
            The wall is taking a little break. Come back later — the blank
            space is intentional.
          </span>
        </div>
      </section>
      <div style={{ minHeight: "40vh" }}>
      </div>
    </main>
  );
}

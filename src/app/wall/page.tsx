import Navbar from "@/components/Navbar";
import InfiniteWall from "@/components/InfiniteWall";
import styles from "@/app/page.module.css";

export const metadata = {
  title: "TheWall — vlad andrei",
  description: "Permanent infinite collaborative whiteboard and guestbook with live synchronization.",
};

export default function WallPage() {
  return (
    <main className={styles.page} style={{ overflow: "hidden", height: "100vh" }}>
      <Navbar backHref="/" backLabel="Back to Home" />

      <div className={styles.wallPageContainer}>
        <InfiniteWall />
      </div>
    </main>
  );
}

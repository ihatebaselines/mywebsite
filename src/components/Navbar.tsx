import Link from "next/link";
import styles from "@/app/page.module.css";

export default function Navbar({
  backHref,
  backLabel,
}: {
  backHref?: string;
  backLabel?: string;
}) {
  return (
    <nav className={styles.nav} aria-label="Main navigation">
      <Link className={styles.mark} href="/">
        ihateb
      </Link>
      {backHref ? (
        <Link className={styles.backLink} href={backHref}>
          {backLabel || "Back"}
        </Link>
      ) : (
        <div className={styles.navLinks}>
          <a href="#last-work">Work</a>
          <Link href="/projects">Projects</Link>
          <Link href="/opensource">Open Source</Link>
          <a href="#portfolio">Portfolio</a>
          <a href="#blog">Blog</a>
          <a href="mailto:rusvlad1010@icloud.com">Contact</a>
        </div>
      )}
    </nav>
  );
}

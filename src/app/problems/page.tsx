import Image from "next/image";
import type { Metadata } from "next";
import styles from "./problems.module.css";

export const metadata: Metadata = {
  title: "Problems — coming soon",
  description: "Competition problems I’ve solved, with explanations and source code. Coming soon.",
};

export default function ProblemsPage() {
  return (
    <main className={`site-main ${styles.main}`}>
      <section className={styles.hero} aria-labelledby="problems-title">
        <div className={styles.copy}>
          <p className={styles.eyebrow}>problems <span>／</span> in the works</p>
          <h1 id="problems-title">coming soon<br />than expected<span>.</span></h1>
          <p className={styles.lede}>
            A collection of competition problems I’ve solved, made for curious builders.
          </p>
          <p className={styles.description}>
            I’m putting together the problem statements, my approaches, and the code behind each solution. The archive and its repository are on the way.
          </p>
          <div className={styles.status}>
            <span className={styles.statusDot} aria-hidden="true" />
            <span>solutions repository</span>
            <strong>coming soon</strong>
          </div>
          <p className={styles.note}>same problems. different ways to think.</p>
        </div>
        <figure className={styles.visual}>
          <Image
            src="/images/problems-cat.png"
            alt="A Siamese cat wearing glasses and thinking over a laptop"
            fill
            priority
            sizes="(max-width: 760px) 100vw, 55vw"
          />
        </figure>
      </section>
    </main>
  );
}

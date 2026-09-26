import Link from "next/link";
import Image from "next/image";
import styles from "./page.module.css";

export default function ButtonsShowcase() {
  return (
    <main className={styles.page}>
      <div className={styles.container}>
        <div className={styles.intro}>
          <div><h1 className={styles.title}>Button Concepts</h1>
          <p className={styles.subtitle}>Here is a showcase of different button styles. Hover over them!</p></div>
          <div className={styles.introArt}><Image src="/images/tilcayo-pixel-perfect.png" alt="Tilcayo cat refining an interface: pixel perfect, mostly" fill sizes="(max-width: 720px) 90vw, 30vw" /></div>
        </div>
        
        <Link href="/" className={styles.backLink}>← Back to Home</Link>

        <div className={styles.grid}>
          {/* Glassmorphism */}
          <div className={styles.card}>
            <h2>1. Glassmorphism</h2>
            <p>Frosted glass effect. Best over gradients or images.</p>
            <div className={styles.demoArea}>
              <a href="#" className={styles.btnGlass}>
                <span>Glass Button</span>
              </a>
            </div>
          </div>

          {/* Cyberpunk */}
          <div className={styles.card}>
            <h2>2. Cyberpunk Glow</h2>
            <p>Neon glow effect on hover. Tech/hacker vibe.</p>
            <div className={styles.demoArea}>
              <a href="#" className={styles.btnCyber}>
                <span>Neon Glow</span>
              </a>
            </div>
          </div>

          {/* Minimalist Premium */}
          <div className={styles.card}>
            <h2>3. Minimalist Premium</h2>
            <p>Deep dark surface with a subtle animated gradient border.</p>
            <div className={styles.demoArea}>
              <a href="#" className={styles.btnMinimal}>
                <span>Elegant Minimal</span>
              </a>
            </div>
          </div>

          {/* Current Style (Retro Dots) */}
          <div className={styles.card}>
            <h2>4. Current Retro Style</h2>
            <p>The original polka-dot brutalist design.</p>
            <div className={styles.demoArea}>
              <a href="#" className={styles.btnRetro}>
                <span>Retro Brutalist</span>
              </a>
            </div>
          </div>

          {/* Catppuccin Theme */}
          <div className={styles.card}>
            <h2>5. Catppuccin (Mocha)</h2>
            <p>Soft pastel colors, soothing dark theme.</p>
            <div className={styles.demoAreaCatppuccin}>
              <a href="#" className={styles.btnCatppuccin}>
                <span>Meow</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}

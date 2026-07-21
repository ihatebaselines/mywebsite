"use client";

import { useState } from "react";
import Link from "next/link";
import styles from "@/app/page.module.css";
import ContactModal from "@/components/ContactModal";
import MegaMenu from "@/components/MegaMenu";

export default function Navbar({
  backHref,
  backLabel,
}: {
  backHref?: string;
  backLabel?: string;
}) {
  const [contactOpen, setContactOpen] = useState(false);
  const [isMegaMenuOpen, setIsMegaMenuOpen] = useState(false);

  const [menuOpen, setMenuOpen] = useState(false);

  let megaMenuTimeout: NodeJS.Timeout;

  const handleMouseEnter = () => {
    clearTimeout(megaMenuTimeout);
    setIsMegaMenuOpen(true);
  };

  const handleMouseLeave = () => {
    megaMenuTimeout = setTimeout(() => {
      setIsMegaMenuOpen(false);
    }, 150);
  };

  return (
    <>
      <nav className={styles.navBar} aria-label="Main navigation">
        <div className={styles.navLeft}>
          <Link className={styles.navBrand} href="/">
            <div className={styles.navLogoContainer}>
              <img src="/images/pingu.png" alt="Pingu logo" className={styles.navLogo} />
            </div>
            <span className={styles.navBrandText}>ihatebaselines</span>
          </Link>
        </div>

        <div className={styles.navCenter}>
          <div 
            className={styles.navMegaTrigger}
            onMouseEnter={handleMouseEnter}
            onMouseLeave={handleMouseLeave}
          >
            <span className={styles.navLinkText}>Work</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className={styles.navCaret}><polyline points="6 9 12 15 18 9"/></svg>
            <MegaMenu 
              isOpen={isMegaMenuOpen} 
              onMouseEnter={handleMouseEnter}
              onMouseLeave={handleMouseLeave}
            />
          </div>
          
          <Link href="/projects" className={styles.navLinkText}>Projects</Link>
          <Link href="/opensource" className={styles.navLinkText}>Open Source</Link>
          <Link href="/blog" className={styles.navLinkText}>Blog</Link>
        </div>

        <div className={styles.navRight}>
          <Link href="https://github.com/ihatebaselines" target="_blank" rel="noopener noreferrer" className={styles.navIconBtn} aria-label="Github">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/>
            </svg>
          </Link>
          <button className={styles.navIconBtn} onClick={() => setContactOpen(true)} aria-label="Contact">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
              <polyline points="22,6 12,13 2,6" />
            </svg>
          </button>
          
          <button
            className={styles.hamburger}
            onClick={() => setMenuOpen(!menuOpen)}
            aria-label="Menu"
          >
            <span className={`${styles.hamburgerLine} ${menuOpen ? styles.hamburgerLineTop : ""}`} />
            <span className={`${styles.hamburgerLine} ${menuOpen ? styles.hamburgerLineMid : ""}`} />
            <span className={`${styles.hamburgerLine} ${menuOpen ? styles.hamburgerLineBot : ""}`} />
          </button>
        </div>
      </nav>

      <div className={`${styles.mobileMenu} ${menuOpen ? styles.mobileMenuOpen : ""}`}>
        <div className={styles.mobileMenuInner}>
          <Link href="/projects" className={styles.mobileNavLink} onClick={() => setMenuOpen(false)}>Projects</Link>
          <Link href="/opensource" className={styles.mobileNavLink} onClick={() => setMenuOpen(false)}>Open Source</Link>
          <Link href="/blog" className={styles.mobileNavLink} onClick={() => setMenuOpen(false)}>Blog</Link>
          <button className={`${styles.mobileNavLink} ${styles.mobileNavContactBtn}`} onClick={() => { setMenuOpen(false); setContactOpen(true); }}>Contact</button>
        </div>
      </div>

      {menuOpen && (
        <div className={styles.mobileMenuBackdrop} onClick={() => setMenuOpen(false)} />
      )}

      <ContactModal open={contactOpen} onClose={() => setContactOpen(false)} />
    </>
  );
}

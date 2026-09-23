"use client";

import Link from "next/link";

const links = [
  { label: "Work", href: "/work" },
  { label: "Blog", href: "/blog" },
  { label: "Projects", href: "/projects" },
  { label: "Problems", href: "/problems" },
  { label: "Open Source", href: "/opensource" },
  { label: "Licenses", href: "/licenses" },
  { label: "Updates", href: "/changelog" },
];

export default function Footer() {
  return (
    <footer className="site-footer">
      <div className="footer-topline">
        <Link className="wordmark" href="/">ihatebaselines<span>.</span></Link>
        <p>curious people build a kinder internet.</p>
      </div>
      <div className="footer-middle">
        <nav aria-label="Footer navigation">
          {links.map((link) => <Link key={link.href} href={link.href}>{link.label}</Link>)}
        </nav>
        <div className="footer-socials">
          <a href="https://github.com/ihatebaselines" target="_blank" rel="noreferrer">GitHub <span aria-hidden="true">↗</span></a>
          <a href="https://www.linkedin.com/in/vladandreirus" target="_blank" rel="noreferrer">LinkedIn <span aria-hidden="true">↗</span></a>
          <a href="mailto:rusvlad1010@icloud.com">Email <span aria-hidden="true">↗</span></a>
        </div>
      </div>
      <div className="footer-bottom">
        <span>© {new Date().getFullYear()} · built slowly, still learning.</span>
        <span>made with curiosity.</span>
        <a href="#top">back to top ↑</a>
      </div>
    </footer>
  );
}

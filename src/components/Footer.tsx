"use client";

import Link from "next/link";

const links = [
  { label: "Work", href: "/work" },
  { label: "Projects", href: "/projects" },
  { label: "Blog", href: "/blog" },
  { label: "Updates", href: "/changelog" },
  { label: "Licenses", href: "/licenses" },
];

const socials = [
  { label: "GitHub", href: "https://github.com/ihatebaselines" },
  { label: "LinkedIn", href: "https://www.linkedin.com/in/vladandreirus" },
  { label: "Instagram", href: "https://www.instagram.com/_rusuuu__" },
  { label: "Email", href: "mailto:rusvlad1010@icloud.com" },
];

export default function Footer() {
  return (
    <footer className="site-footer">
      <span>© {new Date().getFullYear()} ihatebaselines.</span>
      <nav aria-label="Footer navigation">
        {links.map((link) => <Link key={link.href} href={link.href}>{link.label}</Link>)}
      </nav>
      <div className="footer-socials">
        {socials.map((s) => (
          <a key={s.label} href={s.href} target={s.href.startsWith("mailto:") ? undefined : "_blank"} rel="noreferrer">
            {s.label} ↗
          </a>
        ))}
      </div>
    </footer>
  );
}

"use client";

import Link from "next/link";

const links = [
  { label: "work", href: "/work" },
  { label: "projects", href: "/projects" },
  { label: "blog", href: "/blog" },
  { label: "updates", href: "/changelog" },
  { label: "licenses", href: "/licenses" },
];

const socials = [
  { label: "github", href: "https://github.com/ihatebaselines" },
  { label: "linkedin", href: "https://www.linkedin.com/in/vladandreirus" },
  { label: "instagram", href: "https://www.instagram.com/_rusuuu__" },
  { label: "email", href: "mailto:rusvlad1010@icloud.com" },
];

export default function Footer() {
  return (
    <footer className="site-footer">
      <span>© {new Date().getFullYear()} ihatebaselines.</span>
      <nav aria-label="Footer navigation">
        {links.map((link) => (
          <Link key={link.href} href={link.href}>
            {link.label}
          </Link>
        ))}
      </nav>
      <div className="footer-socials">
        {socials.map((s) => (
          <a
            key={s.label}
            href={s.href}
            target={s.href.startsWith("mailto:") ? undefined : "_blank"}
            rel="noreferrer"
          >
            {s.label} ↗
          </a>
        ))}
      </div>
    </footer>
  );
}

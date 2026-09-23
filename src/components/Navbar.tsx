"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef } from "react";
import CommandPalette from "@/components/CommandPalette";

const links = [
  { label: "Work", href: "/work" },
  { label: "Blog", href: "/blog" },
  { label: "Projects", href: "/projects" },
  { label: "Problems", href: "/problems" },
  { label: "Open Source", href: "/opensource" },
  { label: "Licenses", href: "/licenses" },
  { label: "Updates", href: "/changelog" },
];

export default function Navbar() {
  const pathname = usePathname();
  const mobileMenu = useRef<HTMLDetailsElement>(null);

  useEffect(() => { if (mobileMenu.current) mobileMenu.current.open = false; }, [pathname]);

  return (
    <header className="site-header">
      <div className="header-inner">
        <Link className="wordmark" href="/" aria-label="ihatebaselines home">
          ihatebaselines<span>.</span>
        </Link>
        <nav className="desktop-nav" aria-label="Main navigation">
          {links.map((link) => {
            const active = pathname === link.href || pathname.startsWith(`${link.href}/`);
            return <Link key={link.href} href={link.href} aria-current={active ? "page" : undefined}>{link.label}</Link>;
          })}
        </nav>
        <div className="header-actions"><CommandPalette /><Link className="header-cta" href="/contact">Let’s talk <span aria-hidden="true">→</span></Link></div>
        <details className="mobile-menu" ref={mobileMenu}>
          <summary className="menu-toggle" aria-label="Toggle navigation menu" aria-controls="mobile-navigation"><span /><span /></summary>
          <nav id="mobile-navigation" className="mobile-nav" aria-label="Mobile navigation">
            {links.map((link) => (
              <Link key={link.href} href={link.href} aria-current={pathname === link.href ? "page" : undefined}>
                <span>{link.label}</span><span aria-hidden="true">↗</span>
              </Link>
            ))}
            <Link className="mobile-contact" href="/contact">Let’s talk <span aria-hidden="true">→</span></Link>
          </nav>
        </details>
      </div>
    </header>
  );
}

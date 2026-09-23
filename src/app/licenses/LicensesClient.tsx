"use client";

import { useMemo, useState } from "react";

export interface LicenseItem {
  name: string;
  version: string;
  license: string;
  licenseUrl: string;
  category: string;
  author: string;
  website: string;
  repository: string;
  npm: string | null;
  description: string;
}

const categories = [
  "All",
  "Core Framework",
  "Animation & Physics",
  "3D & Graphics",
  "Backend & Database",
  "UI & Icons",
  "Typography & Typefaces",
  "Development Tooling",
];

export default function LicensesClient({ initialLicenses }: { initialLicenses: LicenseItem[] }) {
  const [query, setQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const filtered = useMemo(() => {
    const term = query.trim().toLowerCase();
    return initialLicenses.filter((item) => {
      if (selectedCategory !== "All" && item.category !== selectedCategory) return false;
      return !term || `${item.name} ${item.version} ${item.description} ${item.license} ${item.author} ${item.category}`.toLowerCase().includes(term);
    });
  }, [initialLicenses, query, selectedCategory]);

  return (
    <div>
      <div className="search-controls">
        <label style={{ flex: 1 }}><span className="visually-hidden">Search licenses</span><input className="search-field" type="search" placeholder="Search packages, descriptions, or licenses…" value={query} onChange={(event) => setQuery(event.target.value)} /></label>
        <span className="search-count">{filtered.length} / {initialLicenses.length} packages</span>
      </div>
      <div className="filter-row" aria-label="Filter packages by category">
        {categories.map((category) => <button type="button" className="filter-button" key={category} aria-pressed={selectedCategory === category} onClick={() => setSelectedCategory(category)}>{category}</button>)}
      </div>
      {filtered.length ? <section className="license-grid" aria-label="Open-source licenses">
        {filtered.map((item) => <article className="license-card" key={`${item.name}-${item.version}`}>
          <div>
            <div className="license-card-top"><h2>{item.name}</h2><span className="license-version">{item.version}</span></div>
            <p>by {item.author}</p><p>{item.description}</p>
            <a className="tag" href={item.licenseUrl} target="_blank" rel="noreferrer">{item.license}</a>
          </div>
          <div className="license-links">{item.repository ? <a href={item.repository} target="_blank" rel="noreferrer">Repository ↗</a> : null}{item.website ? <a href={item.website} target="_blank" rel="noreferrer">Website ↗</a> : null}{item.npm ? <a href={item.npm} target="_blank" rel="noreferrer">npm ↗</a> : null}</div>
        </article>)}
      </section> : <p className="empty-state">No packages found. Try a different search.</p>}
    </div>
  );
}

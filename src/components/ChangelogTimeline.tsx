"use client";

import { useMemo, useState } from "react";
import { changelog } from "@/content/changelog";

const filters = [
  { label: "All", value: "all" },
  { label: "Features", value: "feature" },
  { label: "Competitions", value: "competition" },
  { label: "Milestones", value: "milestone" },
  { label: "System", value: "system" },
];

export default function ChangelogTimeline() {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState("all");
  const results = useMemo(() => {
    const term = query.trim().toLowerCase();
    return changelog.filter((item) => {
      const inCategory = selected === "all" || item.tagType === selected;
      const inSearch = !term || `${item.title} ${item.summary} ${item.version} ${item.changes.join(" ")}`.toLowerCase().includes(term);
      return inCategory && inSearch;
    });
  }, [query, selected]);

  return (
    <div>
      <div className="search-controls">
        <label style={{ flex: 1 }}><span className="visually-hidden">Search updates</span><input className="search-field" type="search" placeholder="Search updates…" value={query} onChange={(event) => setQuery(event.target.value)} /></label>
        <span className="search-count">{results.length} / {changelog.length}</span>
      </div>
      <div className="filter-row" aria-label="Filter updates">
        {filters.map((filter) => <button className="filter-button" type="button" key={filter.value} aria-pressed={selected === filter.value} onClick={() => setSelected(filter.value)}>{filter.label}</button>)}
      </div>
      {results.length ? <div className="update-list">
        {results.map((item) => <article className="update-card" key={item.version}>
          <div className="update-version"><strong>{item.version}</strong><span>{item.date}</span><span className="tag">{item.tag}</span></div>
          <div className="update-copy"><h2>{item.title}</h2><p>{item.summary}</p>{item.quote ? <p className="update-quote">“{item.quote}”</p> : null}</div>
          <ul>{item.changes.map((change, index) => <li key={`${item.version}-${index}`}>{change}</li>)}</ul>
        </article>)}
      </div> : <p className="empty-state">No updates match that search.</p>}
    </div>
  );
}

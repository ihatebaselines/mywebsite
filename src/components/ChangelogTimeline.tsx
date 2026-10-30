"use client";

import Image from "next/image";
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
      const inSearch =
        !term ||
        `${item.title} ${item.summary} ${item.version} ${item.codename || ""} ${item.changes.join(" ")}`
          .toLowerCase()
          .includes(term);
      return inCategory && inSearch;
    });
  }, [query, selected]);

  return (
    <div>
      <div className="search-controls">
        <label className="search-field-wrap" style={{ flex: 1 }}>
          <span className="visually-hidden">Search updates</span>
          <input
            className="search-field"
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search updates by title, date, or topic…"
          />
        </label>
        <span className="search-count">
          {results.length} / {changelog.length} updates
        </span>
      </div>

      <div className="filter-row" aria-label="Filter updates">
        {filters.map((filter) => (
          <button
            className="filter-button"
            type="button"
            key={filter.value}
            aria-pressed={selected === filter.value}
            onClick={() => setSelected(filter.value)}
          >
            {filter.label}
          </button>
        ))}
      </div>

      {results.length ? (
        <div className="listing-grid">
          {results.map((item) => {
            const currentImg =
              item.image || "/images/updates/normal/update_1_0.jpg";

            return (
              <article className="entry-card" key={item.version}>
                <div className="entry-card-link">
                  <div className="entry-image">
                    <Image
                      src={currentImg}
                      alt=""
                      fill
                      sizes="(max-width: 720px) 90vw, 45vw"
                    />
                  </div>
                  <div className="entry-copy">
                    <p className="entry-meta">
                      {item.tag ? `${item.tag.toUpperCase()} · ` : ""}
                      {item.date}
                    </p>
                    <h2>{item.title}</h2>
                    <p>{item.summary}</p>
                    <span className="entry-arrow" aria-hidden="true">
                      →
                    </span>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      ) : (
        <p className="empty-state">No updates match “{query}”. Try another search.</p>
      )}
    </div>
  );
}

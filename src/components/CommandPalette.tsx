"use client";

import React, { useState, useEffect, useMemo, useCallback, useRef } from "react";
import { useRouter } from "next/navigation";
import {
  Search,
  Command,
  Trophy,
  BookOpen,
  FolderGit2,
  FileCode,
  PenTool,
  History,
  Copy,
  Check,
  ExternalLink,
  Sparkles,
  ArrowRight,
  X,
  Compass,
} from "lucide-react";
import postsData from "@/content/postsData.json";
import awardsData from "@/content/awardsData.json";
import projectsData from "@/content/projectsData.json";
import opensourceData from "@/content/opensourceData.json";
import changelogData from "@/content/changelogData.json";
import styles from "@/app/page.module.css";

interface PaletteItem {
  id: string;
  title: string;
  subtitle?: string;
  category: "Navigation" | "Competitions" | "Blog" | "Projects" | "Actions";
  icon: React.ReactNode;
  url?: string;
  action?: () => void;
  badge?: string;
}

export default function CommandPalette() {
  const [isOpen, setIsOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [copiedText, setCopiedText] = useState<string | null>(null);

  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLDivElement>(null);

  // All searchable items
  const allItems: PaletteItem[] = useMemo(() => {
    const items: PaletteItem[] = [
      // Quick Actions & Navigation
      {
        id: "nav-home",
        title: "Home",
        subtitle: "Back to main overview and interactive pingus",
        category: "Navigation",
        icon: <Compass size={16} />,
        url: "/",
        badge: "Page",
      },
      {
        id: "nav-wall",
        title: "TheWall",
        subtitle: "Permanent live whiteboard, draw doodles & leave signed notes",
        category: "Navigation",
        icon: <PenTool size={16} />,
        url: "/wall",
        badge: "Interactive",
      },
      {
        id: "nav-changelog",
        title: "Changelog & Updates",
        subtitle: "Release history, competition timeline & updates",
        category: "Navigation",
        icon: <History size={16} />,
        url: "/changelog",
        badge: "Log",
      },
      {
        id: "nav-blog",
        title: "Blog & Stories",
        subtitle: "Search all diaries, competition writeups & notes",
        category: "Navigation",
        icon: <BookOpen size={16} />,
        url: "/blog",
        badge: "Posts",
      },
      {
        id: "nav-work",
        title: "Work & Competitions",
        subtitle: "Detailed contest problem breakdowns and solutions",
        category: "Navigation",
        icon: <FolderGit2 size={16} />,
        url: "/work",
        badge: "Work",
      },
      {
        id: "nav-projects",
        title: "Projects",
        subtitle: "Featured research, apps and AI builds",
        category: "Navigation",
        icon: <FolderGit2 size={16} />,
        url: "/projects",
        badge: "Builds",
      },
      {
        id: "nav-opensource",
        title: "Open Source",
        subtitle: "Libraries, SocrateX and GitHub repositories",
        category: "Navigation",
        icon: <FileCode size={16} />,
        url: "/opensource",
        badge: "GitHub",
      },

      // Actions
      {
        id: "action-discord",
        title: "Copy Discord Username",
        subtitle: "Copy @ihatebaselines / 934847546432581682",
        category: "Actions",
        icon: copiedText === "Discord" ? <Check size={16} color="#a6e3a1" /> : <Copy size={16} />,
        action: () => {
          navigator.clipboard.writeText("ihatebaselines");
          setCopiedText("Discord");
          setTimeout(() => setCopiedText(null), 2000);
        },
        badge: copiedText === "Discord" ? "Copied!" : "Action",
      },
      {
        id: "action-linkedin",
        title: "Open LinkedIn Profile",
        subtitle: "linkedin.com/in/vladandreirus",
        category: "Actions",
        icon: <ExternalLink size={16} />,
        action: () => {
          window.open("https://www.linkedin.com/in/vladandreirus", "_blank");
        },
        badge: "External",
      },
      {
        id: "action-github",
        title: "Open GitHub Profile",
        subtitle: "github.com/ihatebaselines",
        category: "Actions",
        icon: <ExternalLink size={16} />,
        action: () => {
          window.open("https://github.com/ihatebaselines", "_blank");
        },
        badge: "External",
      },

      // Competitions & Achievements
      ...awardsData.map((award) => ({
        id: `award-${award.id}`,
        title: award.title,
        subtitle: `${award.event} • ${award.description.slice(0, 75)}...`,
        category: "Competitions" as const,
        icon: <Trophy size={16} color="#f9e2af" />,
        url: award.links?.[0]?.url || "/blog/from-algorithms-to-neurons",
        badge: award.badge,
      })),

      // Blog posts
      ...postsData.map((post) => ({
        id: `post-${post.slug}`,
        title: post.title,
        subtitle: `${post.category} • ${post.excerpt}`,
        category: "Blog" as const,
        icon: <BookOpen size={16} color="#89b4fa" />,
        url: `/blog/${post.slug}`,
        badge: post.date,
      })),

      // Projects & Open Source
      ...projectsData.map((project) => ({
        id: `proj-${project.slug}`,
        title: project.title,
        subtitle: project.description,
        category: "Projects" as const,
        icon: <FolderGit2 size={16} color="#a6e3a1" />,
        url: `/projects#${project.slug}`,
        badge: "Project",
      })),
      ...opensourceData.map((os) => ({
        id: `os-${os.slug}`,
        title: os.name,
        subtitle: os.description,
        category: "Projects" as const,
        icon: <FileCode size={16} color="#cba6f7" />,
        url: os.repoUrl,
        badge: "Package",
      })),
    ];

    return items;
  }, [copiedText]);

  // Filter items by query
  const filteredItems = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) {
      // Default top suggestions
      return allItems.slice(0, 12);
    }

    return allItems
      .filter((item) => {
        const text = `${item.title} ${item.subtitle || ""} ${item.category} ${item.badge || ""}`.toLowerCase();
        return text.includes(q);
      })
      .slice(0, 15);
  }, [allItems, query]);

  // Keyboard shortcut listener: Ctrl+K or Cmd+K
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setIsOpen((prev) => !prev);
      } else if (e.key === "Escape" && isOpen) {
        setIsOpen(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen]);

  // Focus input when opened
  useEffect(() => {
    if (isOpen) {
      setQuery("");
      setSelectedIndex(0);
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [isOpen]);

  // Reset selected index when filtered items change
  useEffect(() => {
    setSelectedIndex(0);
  }, [filteredItems]);

  const handleSelect = useCallback(
    (item: PaletteItem) => {
      setIsOpen(false);
      if (item.action) {
        item.action();
      } else if (item.url) {
        if (item.url.startsWith("http")) {
          window.open(item.url, "_blank");
        } else {
          router.push(item.url);
        }
      }
    },
    [router]
  );

  const handleInputKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSelectedIndex((prev) => (prev + 1) % filteredItems.length);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setSelectedIndex((prev) => (prev - 1 + filteredItems.length) % filteredItems.length);
    } else if (e.key === "Enter" && filteredItems[selectedIndex]) {
      e.preventDefault();
      handleSelect(filteredItems[selectedIndex]);
    }
  };

  // Scroll active item into view
  useEffect(() => {
    if (listRef.current) {
      const activeEl = listRef.current.children[selectedIndex] as HTMLElement;
      if (activeEl) {
        activeEl.scrollIntoView({ block: "nearest" });
      }
    }
  }, [selectedIndex]);

  if (!isOpen) {
    return (
      <button
        type="button"
        className={styles.cmdPaletteTrigger}
        onClick={() => setIsOpen(true)}
        aria-label="Open Command Palette (Ctrl+K)"
        title="Command Palette (Ctrl + K)"
      >
        <Search size={14} className={styles.cmdTriggerIcon} />
        <span className={styles.cmdTriggerText}>Search...</span>
        <kbd className={styles.cmdTriggerKbd}>⌘K</kbd>
      </button>
    );
  }

  return (
    <div
      className={styles.cmdOverlay}
      onClick={() => setIsOpen(false)}
      role="dialog"
      aria-modal="true"
    >
      <div
        className={styles.cmdDialog}
        onClick={(e) => e.stopPropagation()}
      >
        <div className={styles.cmdInputRow}>
          <Search size={18} className={styles.cmdSearchIcon} />
          <input
            ref={inputRef}
            type="text"
            className={styles.cmdInput}
            placeholder="Search competitions, posts, awards, actions... (or Esc)"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onKeyDown={handleInputKeyDown}
          />
          {query ? (
            <button
              type="button"
              className={styles.cmdClearBtn}
              onClick={() => setQuery("")}
            >
              <X size={15} />
            </button>
          ) : (
            <kbd className={styles.cmdEscKbd}>ESC</kbd>
          )}
        </div>

        <div className={styles.cmdList} ref={listRef}>
          {filteredItems.length === 0 ? (
            <div className={styles.cmdEmpty}>
              <Sparkles size={20} className={styles.cmdEmptyIcon} />
              <p>No results found for &ldquo;{query}&rdquo;</p>
              <span>Try searching for &quot;1st Place&quot;, &quot;Neurons&quot;, &quot;Wall&quot; or &quot;Discord&quot;</span>
            </div>
          ) : (
            filteredItems.map((item, index) => {
              const isSelected = index === selectedIndex;
              return (
                <div
                  key={item.id}
                  className={`${styles.cmdItem} ${isSelected ? styles.cmdItemSelected : ""}`}
                  onClick={() => handleSelect(item)}
                  onMouseEnter={() => setSelectedIndex(index)}
                >
                  <div className={styles.cmdItemIcon}>{item.icon}</div>
                  <div className={styles.cmdItemContent}>
                    <div className={styles.cmdItemTitleRow}>
                      <span className={styles.cmdItemTitle}>{item.title}</span>
                      {item.badge && (
                        <span className={styles.cmdItemBadge}>{item.badge}</span>
                      )}
                    </div>
                    {item.subtitle && (
                      <p className={styles.cmdItemSubtitle}>{item.subtitle}</p>
                    )}
                  </div>
                  <ArrowRight size={14} className={styles.cmdItemArrow} />
                </div>
              );
            })
          )}
        </div>

        <div className={styles.cmdFooter}>
          <div className={styles.cmdShortcuts}>
            <span><kbd>↑</kbd><kbd>↓</kbd> Navigate</span>
            <span><kbd>↵</kbd> Select</span>
            <span><kbd>ESC</kbd> Close</span>
          </div>
          <span className={styles.cmdFooterTag}>ihatebaselines • Raycast UI</span>
        </div>
      </div>
    </div>
  );
}

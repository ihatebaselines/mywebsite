"use client";

import React, { useState } from "react";
import Image from "next/image";
import { Check, Copy, Clock, Layers, Sparkles, Cpu, GitBranch, ArrowRight, Zap } from "lucide-react";

interface TimelineItem {
  date: string;
  title: string;
  description: string;
  badge?: string;
}

function CodeBlock({ code, lang, title }: { code: string; lang?: string; title?: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="article-code-container">
      <div className="article-code-header">
        <div className="article-code-meta">
          <span className="code-dot" />
          <span className="code-filename">{title || (lang ? `snippet.${lang}` : "code")}</span>
        </div>
        <div className="article-code-actions">
          {lang && <span className="code-lang-badge">{lang}</span>}
          <button
            type="button"
            onClick={handleCopy}
            className="code-copy-btn"
            title="Copy code"
            aria-label="Copy code to clipboard"
          >
            {copied ? (
              <>
                <Check size={13} style={{ color: "var(--accent)" }} />
                <span>Copied</span>
              </>
            ) : (
              <>
                <Copy size={13} />
                <span>Copy</span>
              </>
            )}
          </button>
        </div>
      </div>
      <pre className="article-code-pre">
        <code>{code}</code>
      </pre>
    </div>
  );
}

function TimelineView({ items }: { items: TimelineItem[] }) {
  return (
    <div className="article-timeline-wrap">
      <div className="timeline-spine" />
      <div className="timeline-items">
        {items.map((item, idx) => (
          <div key={idx} className="timeline-node">
            <div className="timeline-dot">
              <span className="timeline-inner-dot" />
            </div>
            <div className="timeline-content">
              <div className="timeline-header">
                <span className="timeline-date">{item.date}</span>
                {item.badge && <span className="timeline-badge">{item.badge}</span>}
              </div>
              <h4 className="timeline-title">{item.title}</h4>
              <p className="timeline-desc">{item.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function FormulaCard({
  title,
  math,
  description,
  variables,
}: {
  title: string;
  math: string;
  description?: string;
  variables?: { name: string; meaning: string }[];
}) {
  return (
    <div className="article-formula-card">
      <div className="formula-header">
        <Sparkles size={14} style={{ color: "var(--accent)" }} />
        <span className="formula-title">{title}</span>
      </div>
      <div className="formula-math-display">
        <code>{math}</code>
      </div>
      {description && <p className="formula-desc">{description}</p>}
      {variables && variables.length > 0 && (
        <div className="formula-vars">
          {variables.map((v, i) => (
            <div key={i} className="formula-var-row">
              <code className="var-name">{v.name}</code>
              <span className="var-sep">:</span>
              <span className="var-desc">{v.meaning}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function SwiftFoxArchitectureDiagram() {
  return (
    <div className="architecture-diagram-card">
      <div className="diagram-header">
        <div className="diagram-title-row">
          <Layers size={15} style={{ color: "var(--accent)" }} />
          <strong>SwiftFox Pipeline & Multimodal Dataflow</strong>
        </div>
        <span className="diagram-subtitle">From Raw Inputs to Autoregressive Token Generation</span>
      </div>

      <div className="diagram-grid">
        {/* Step 1: Inputs */}
        <div className="diagram-step-box">
          <span className="step-num">01 / INPUTS</span>
          <h4>Dual-Modal Ingestion</h4>
          <p>
            Supports pure <strong>Text → Text</strong> or <strong>Image + Text → Text</strong> (up to 3 images per context).
          </p>
          <div className="diagram-tokens-demo">
            <span className="token-tag img-tag">IMG_1..3</span>
            <span className="token-plus">+</span>
            <span className="token-tag txt-tag">Text Prompt</span>
          </div>
        </div>

        {/* Step 2: Embeddings */}
        <div className="diagram-step-box">
          <span className="step-num">02 / EMBEDDINGS</span>
          <h4>Residual 2D + nn.Embedding</h4>
          <p>
            Images are sliced into patches and projected via <strong>2D Residual Blocks (1x1 Conv)</strong>. Text is mapped through <code>nn.Embedding</code>.
          </p>
          <div className="sequence-preview">
            <code>[IMG_1]..[IMG_N] [TXT_1]..[TXT_M]</code>
          </div>
        </div>

        {/* Step 3: Attention */}
        <div className="diagram-step-box">
          <span className="step-num">03 / ATTENTION</span>
          <h4>RoPE Multi-Head Attention</h4>
          <p>
            Rotary Position Embeddings rotate Q &amp; K pairs. Invariant to absolute position, ensuring natural visual-textual relative decay.
          </p>
          <div className="tech-badge-row">
            <span className="tech-badge">RoPE</span>
            <span className="tech-badge">Self-Attention</span>
            <span className="tech-badge">Causal Mask</span>
          </div>
        </div>

        {/* Step 4: MoE & Loss */}
        <div className="diagram-step-box">
          <span className="step-num">04 / ROUTING &amp; MoE</span>
          <h4>Adaptive Top-K with SwiGLU</h4>
          <p>
            Shannon entropy <code>H(x)</code> dynamically adjusts K experts. Next-token prediction trained with <code>L_CE + L_LB</code>.
          </p>
          <div className="tech-badge-row">
            <span className="tech-badge">SwiGLU</span>
            <span className="tech-badge">Entropy Router</span>
            <span className="tech-badge">Load Balance</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function renderFormattedInline(text: string): React.ReactNode[] {
  const regex = /(\[[^\]]+\]\(https?:\/\/[^\s)]+\)|\*\*[^*]+\*\*|`[^`]+`)/g;
  const parts = text.split(regex);
  return parts.map((part, i) => {
    if (part.startsWith("[") && part.includes("](")) {
      const match = /^\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)$/.exec(part);
      if (match) {
        return (
          <a
            key={i}
            href={match[2]}
            target="_blank"
            rel="noreferrer"
            className="text-link"
            style={{ display: "inline", textDecoration: "underline", textUnderlineOffset: "3px" }}
          >
            {match[1]}
          </a>
        );
      }
    }
    if (part.startsWith("**") && part.endsWith("**")) {
      return (
        <strong key={i} style={{ color: "var(--text)", fontWeight: 600 }}>
          {part.slice(2, -2)}
        </strong>
      );
    }
    if (part.startsWith("`") && part.endsWith("`")) {
      return (
        <code
          key={i}
          style={{
            background: "var(--surface-soft)",
            padding: "2px 6px",
            borderRadius: "4px",
            border: "1px solid var(--border)",
            fontSize: "0.85em",
            color: "var(--accent-dark)",
            fontFamily: "var(--font)",
          }}
        >
          {part.slice(1, -1)}
        </code>
      );
    }
    return part;
  });
}

export default function ArticleContent({ body }: { body: string[] }) {
  return (
    <div className="article-body">
      {body.map((item, index) => {
        // 1. Headings
        if (item.startsWith("## ")) {
          const title = item.replace("## ", "").trim();
          return (
            <h2 key={index} className="article-h2">
              {title}
              <span className="title-period">.</span>
            </h2>
          );
        }

        if (item.startsWith("### ")) {
          const title = item.replace("### ", "").trim();
          return (
            <h3 key={index} className="article-h3">
              {title}
            </h3>
          );
        }

        // 2. Timeline
        if (item.startsWith("timeline:")) {
          const rawLines = item.replace("timeline:", "").trim().split("\n");
          const items: TimelineItem[] = [];
          for (const line of rawLines) {
            const parts = line.split("|").map((s) => s.trim());
            if (parts.length >= 3) {
              items.push({
                date: parts[0],
                title: parts[1],
                description: parts[2],
                badge: parts[3],
              });
            }
          }
          return <TimelineView key={index} items={items} />;
        }

        // 3. Architecture Diagram
        if (item.startsWith("diagram:swiftfox_flow")) {
          return <SwiftFoxArchitectureDiagram key={index} />;
        }

        // 4. Formula Card
        if (item.startsWith("formula:")) {
          const rawLines = item.replace("formula:", "").trim().split("\n");
          const title = rawLines[0] || "Equation";
          let math = "";
          let desc = "";
          const variables: { name: string; meaning: string }[] = [];

          for (let i = 1; i < rawLines.length; i++) {
            const line = rawLines[i].trim();
            if (line.startsWith("math:")) {
              math = line.replace("math:", "").trim();
            } else if (line.startsWith("desc:")) {
              desc = line.replace("desc:", "").trim();
            } else if (line.startsWith("var:")) {
              const [vName, ...vRest] = line.replace("var:", "").split("=");
              if (vName && vRest.length) {
                variables.push({ name: vName.trim(), meaning: vRest.join("=").trim() });
              }
            }
          }

          return (
            <FormulaCard
              key={index}
              title={title}
              math={math}
              description={desc}
              variables={variables}
            />
          );
        }

        // 5. Code Block
        if (item.startsWith("code:")) {
          const lines = item.split("\n");
          const metaLine = lines[0].replace("code:", "").trim();
          const metaParts = metaLine.split(":");
          const lang = metaParts[0] || "python";
          const title = metaParts[1] || "";
          const code = lines.slice(1).join("\n");
          return <CodeBlock key={index} code={code} lang={lang} title={title} />;
        }

        // 6. Callout
        if (item.startsWith("callout:")) {
          const content = item.replace("callout:", "").trim();
          return (
            <div key={index} className="article-callout">
              <div className="callout-indicator">
                <Zap size={14} style={{ color: "var(--accent)" }} />
              </div>
              <div className="callout-body">{renderFormattedInline(content)}</div>
            </div>
          );
        }

        // 7. Bullet List
        if (item.startsWith("list:")) {
          const lines = item.replace("list:", "").trim().split("\n");
          return (
            <ul key={index} className="article-bullet-list">
              {lines.map((l, li) => (
                <li key={li}>{renderFormattedInline(l.replace(/^[-*]\s*/, ""))}</li>
              ))}
            </ul>
          );
        }

        // 8. Legacy img / images support
        if (item.startsWith("img:")) {
          const src = item.replace("img:", "").trim();
          return (
            <div
              key={index}
              style={{
                margin: "24px 0",
                position: "relative",
                width: "100%",
                maxHeight: "480px",
                overflow: "hidden",
                borderRadius: "6px",
                border: "1px solid var(--border)",
              }}
            >
              <img
                src={src}
                alt="blog visual"
                style={{ width: "100%", height: "auto", objectFit: "contain", display: "block" }}
              />
            </div>
          );
        }

        if (item.startsWith("images:")) {
          const srcs = item
            .replace("images:", "")
            .split(",")
            .map((s) => s.trim());
          return (
            <div
              key={index}
              style={{
                display: "grid",
                gridTemplateColumns: `repeat(${Math.min(srcs.length, 3)}, 1fr)`,
                gap: "10px",
                margin: "24px 0",
              }}
            >
              {srcs.map((src, i) => (
                <div
                  key={i}
                  style={{
                    borderRadius: "6px",
                    overflow: "hidden",
                    border: "1px solid var(--border)",
                  }}
                >
                  <img
                    src={src}
                    alt={`gallery item ${i}`}
                    style={{ width: "100%", height: "100%", objectFit: "cover" }}
                  />
                </div>
              ))}
            </div>
          );
        }

        // Standard Paragraph
        return <p key={index}>{renderFormattedInline(item)}</p>;
      })}
    </div>
  );
}

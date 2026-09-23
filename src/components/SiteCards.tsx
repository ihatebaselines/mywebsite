import Image from "next/image";
import Link from "next/link";

export function PageIntro({
  eyebrow,
  title,
  description,
  aside,
}: {
  eyebrow: string;
  title: string;
  description: string;
  aside?: string;
}) {
  return (
    <header className="page-intro">
      <div className="page-intro-main">
        <span className="eyebrow">{eyebrow}</span>
        <h1 className="page-title">{title}<span className="title-period">.</span></h1>
        <p className="page-description">{description}</p>
      </div>
      {aside ? <p className="intro-aside">{aside}</p> : null}
    </header>
  );
}

export function EntryCard({
  href,
  title,
  description,
  meta,
  image,
  tags = [],
  featured = false,
}: {
  href: string;
  title: string;
  description: string;
  meta?: string;
  image?: string;
  tags?: string[];
  featured?: boolean;
}) {
  return (
    <article className={`entry-card${featured ? " entry-card-featured" : ""}`}>
      <Link className="entry-card-link" href={href}>
        {image ? <div className="entry-image"><Image src={image} alt="" fill sizes="(max-width: 720px) 90vw, (max-width: 1050px) 45vw, 35vw" /></div> : null}
        <div className="entry-copy">
          {meta ? <p className="entry-meta">{meta}</p> : null}
          <h2>{title}</h2>
          <p>{description}</p>
          {tags.length ? <div className="tag-list">{tags.slice(0, 4).map((tag) => <span className="tag" key={tag}>{tag}</span>)}</div> : null}
          <span className="entry-arrow" aria-hidden="true">→</span>
        </div>
      </Link>
    </article>
  );
}

export function ExternalEntryCard({
  href,
  title,
  description,
  meta,
  tags = [],
}: {
  href: string;
  title: string;
  description: string;
  meta?: string;
  tags?: string[];
}) {
  return (
    <a className="entry-card" href={href} target="_blank" rel="noreferrer">
      <div className="repo-card">
        <div className="repo-card-top"><span>{meta ?? "OPEN SOURCE"}</span><span aria-hidden="true">↗</span></div>
        <h3>{title}</h3>
        <p>{description}</p>
        {tags.length ? <div className="tag-list">{tags.slice(0, 4).map((tag) => <span className="tag" key={tag}>{tag}</span>)}</div> : null}
      </div>
    </a>
  );
}

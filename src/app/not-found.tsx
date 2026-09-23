import Link from "next/link";

export default function NotFound() {
  return (
    <main className="site-main"><section className="page-intro error-page">
      <div><span className="eyebrow">404 / not found</span><h1 className="page-title">nothing here<span className="title-period">.</span></h1><p className="page-description">This page may have moved, or it may never have existed.</p><Link href="/" className="button button-primary">Back home →</Link></div>
    </section></main>
  );
}

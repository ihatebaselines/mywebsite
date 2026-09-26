import Image from "next/image";
import Link from "next/link";

export default function NotFound() {
  return (
    <main className="site-main"><section className="page-intro page-intro-illustrated error-page">
      <div><span className="eyebrow">404 / not found</span><h1 className="page-title">nothing here<span className="title-period">.</span></h1><p className="page-description">This page may have moved, or it may never have existed.</p><Link href="/" className="button button-primary">Back home →</Link></div>
      <figure className="intro-illustration"><Image src="/images/tilcayo-404-still-looking.png" alt="Tilcayo cat peeking over a 404 window: still looking" fill priority sizes="(max-width: 720px) 90vw, 35vw" /></figure>
    </section></main>
  );
}

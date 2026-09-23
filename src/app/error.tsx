"use client";

import { useEffect } from "react";
import Link from "next/link";

export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => console.error(error), [error]);
  return (
    <main className="site-main"><section className="page-intro error-page">
      <div><span className="eyebrow">something went wrong</span><h1 className="page-title">let’s try that again<span className="title-period">.</span></h1><p className="page-description">The page hit an unexpected error. Your place here is safe.</p>
        <div className="button-row"><button className="button button-primary" onClick={reset}>Try again →</button><Link className="button" href="/">Back home</Link></div>
      </div>
    </section></main>
  );
}

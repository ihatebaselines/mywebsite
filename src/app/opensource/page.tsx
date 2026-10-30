"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

export default function OpenSourceRedirect() {
  const router = useRouter();

  useEffect(() => {
    router.replace("/projects");
  }, [router]);

  return (
    <main className="site-main" style={{ padding: "100px 0", textAlign: "center" }}>
      <p>Open Source has moved into Projects.</p>
      <p style={{ marginTop: "16px" }}>
        <Link className="text-link" href="/projects">
          Go to Projects <span aria-hidden="true">→</span>
        </Link>
      </p>
    </main>
  );
}

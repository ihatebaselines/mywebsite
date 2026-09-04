import type { Metadata } from "next";
import PremiumEffects from "@/components/PremiumEffects";
import SmoothScroll from "@/components/SmoothScroll";
import Footer from "@/components/Footer";
import LoadingScreen from "@/components/LoadingScreen";
import EasterEggs from "@/components/EasterEggs";
import "lenis/dist/lenis.css";
import "react-loading-skeleton/dist/skeleton.css";
import "./globals.css";

export const metadata: Metadata = {
  title: "ihatebaselines · vlad andrei",
  description: "Portfolio, blog and projects by Vlad Andrei — AI, competitive programming, math.",
  metadataBase: new URL("https://ihatebaselines.com"),
  openGraph: {
    title: "ihatebaselines · vlad andrei",
    description: "Portfolio, blog and projects by Vlad Andrei — AI, competitive programming, math.",
    url: "https://ihatebaselines.com",
    siteName: "ihatebaselines",
    type: "website",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "ihatebaselines portfolio",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ihatebaselines · vlad andrei",
    description: "Portfolio, blog and projects by Vlad Andrei.",
    images: ["/og-image.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){
              try {
                var m = localStorage.getItem("ihateb_mode");
                if (m === "one" || m === "zero") {
                  document.documentElement.setAttribute("data-theme", m);
                }
              } catch(e){}

              try {
                console.log(
                  "%cyou found the console.\\ncongrats, debugger.\\n\\ntry:\\n  ihatebaselines.zero()\\n  ihatebaselines.one()\\n  ihatebaselines.pingu()",
                  "font-family: monospace; font-size: 13px; font-weight: 700; color: #10b981; line-height: 1.5;"
                );

                window.ihatebaselines = {
                  zero: function() {
                    try { localStorage.setItem("ihateb_mode", "zero"); } catch(e){}
                    document.documentElement.setAttribute("data-theme", "zero");
                    window.dispatchEvent(new CustomEvent("trigger-mode-transition", { detail: { mode: "zero" } }));
                    window.dispatchEvent(new CustomEvent("theme-change", { detail: { mode: "zero" } }));
                    return "0: dark void activated.";
                  },
                  one: function() {
                    try { localStorage.setItem("ihateb_mode", "one"); } catch(e){}
                    document.documentElement.setAttribute("data-theme", "one");
                    window.dispatchEvent(new CustomEvent("trigger-mode-transition", { detail: { mode: "one" } }));
                    window.dispatchEvent(new CustomEvent("theme-change", { detail: { mode: "one" } }));
                    return "1: white theme activated.";
                  },
                  pingu: function() {
                    window.dispatchEvent(new CustomEvent("ihateb-spawn-pingu"));
                    return "🐧 pingu spawned.";
                  },
                  toString: function() {
                    return "ihatebaselines console API. Try: ihatebaselines.zero(), ihatebaselines.one(), ihatebaselines.pingu()";
                  }
                };
              } catch(e){}
            })();`,
          }}
        />
      </head>
      <body>
        <LoadingScreen />
        <SmoothScroll />
        <PremiumEffects />
        <EasterEggs />
        {children}
        <Footer />
      </body>
    </html>
  );
}

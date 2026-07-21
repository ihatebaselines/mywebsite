import type { Metadata } from "next";
import PremiumEffects from "@/components/PremiumEffects";
import SmoothScroll from "@/components/SmoothScroll";
import Footer from "@/components/Footer";
import LoadingScreen from "@/components/LoadingScreen";
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
    <html lang="en">
      <body>
        <LoadingScreen />
        <SmoothScroll />
        <PremiumEffects />
        {children}
        <Footer />
      </body>
    </html>
  );
}

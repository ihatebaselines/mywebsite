import type { Metadata } from "next";
import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import SmoothScroll from "@/components/SmoothScroll";
import "lenis/dist/lenis.css";
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
      <head>
        <meta name="theme-color" content="#f7f5ef" />
      </head>
      <body id="top">
        <Navbar />
        <SmoothScroll />
        {children}
        <Footer />
      </body>
    </html>
  );
}

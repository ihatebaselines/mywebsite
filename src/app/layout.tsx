import type { Metadata } from "next";
import PremiumEffects from "@/components/PremiumEffects";
import SmoothScroll from "@/components/SmoothScroll";
import "lenis/dist/lenis.css";
import "react-loading-skeleton/dist/skeleton.css";
import "./globals.css";

export const metadata: Metadata = {
  title: "ihateb portfolio",
  description: "Portfolio and blog with draggable ducks.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <SmoothScroll />
        <PremiumEffects />
        {children}
      </body>
    </html>
  );
}

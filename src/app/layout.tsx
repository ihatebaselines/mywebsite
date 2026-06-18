import type { Metadata } from "next";
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
      <body>{children}</body>
    </html>
  );
}

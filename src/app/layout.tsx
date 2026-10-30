import type { Metadata } from "next";
import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import SmoothScroll from "@/components/SmoothScroll";
import "lenis/dist/lenis.css";
import "./globals.css";

const siteKeywords = [
  // Primary brand & requested keywords
  "ihatebaselines",
  "vlad andrei rus",
  "rus vlad andrei",
  "vlad andrei",
  "vlad andrei cluj",
  "cluj",
  "rus vlad",
  "vlad rus",
  "vladandrei",
  "vladandreirus",
  "rusvladandrei",
  "i hate baselines",
  "ihatebaselines.com",
  "ihatebaseline",
  "ihb",
  "@ihatebaselines",

  // Location & Education
  "cluj-napoca",
  "cluj napoca",
  "romania",
  "transylvania",
  "colegiul national emil racovita",
  "emil racovita cluj",
  "cner cluj",
  "cner",
  "racovita cluj",
  "elev cluj",
  "student cluj",
  "programator cluj",
  "cluj ai",
  "cluj developer",
  "romania developer",
  "romanian ai researcher",
  "vlad andrei portofoliu",
  "vlad andrei cv",
  "vlad andrei github",

  // AI & Machine Learning
  "machine learning",
  "deep learning",
  "artificial intelligence",
  "ai",
  "ml",
  "neural networks",
  "computer vision",
  "cv",
  "natural language processing",
  "nlp",
  "large language models",
  "llm",
  "llms",
  "vision language models",
  "vlm",
  "multimodal ai",
  "transformers",
  "attention mechanism",
  "self-attention",
  "pytorch",
  "tensorflow",
  "jax",
  "cuda",
  "reinforcement learning",
  "rl",
  "diffusion models",
  "generative ai",
  "ai research",
  "ai engineer",
  "ml engineer",
  "deep learning engineer",
  "data science",
  "data scientist",
  "applied ai",
  "fine-tuning",
  "peft",
  "lora",
  "quantization",
  "model distillation",
  "inference optimization",
  "tensorrt",
  "onnx",
  "backpropagation",
  "convolutional neural networks",
  "cnn",
  "recurrent neural networks",
  "rnn",
  "embedding models",
  "latent space",
  "perplexity",
  "ai architectures",
  "pretrained language model",
  "zero-shot learning",
  "synthetic data generation",

  // Competitions & Hackathons
  "competitive programming",
  "cp",
  "kaggle",
  "kaggle competitions",
  "kaggle master",
  "kaggle notebooks",
  "catalysts coding contest",
  "ccc",
  "ccc 2026",
  "romanian space design competition",
  "rosdc",
  "rosdc 2026",
  "operations condor",
  "hackathons",
  "hackathon winner",
  "algorithm design",
  "algorithmic problem solving",
  "codeforces",
  "leetcode",
  "infoarena",
  "olimpiada de informatica",
  "oni",
  "olimpiada de matematica",
  "onm",
  "algorithms",
  "data structures",
  "graph algorithms",
  "dynamic programming",
  "combinatorics",

  // Software Engineering & Tech Stack
  "software engineer",
  "software developer",
  "full stack developer",
  "frontend developer",
  "backend developer",
  "creative developer",
  "next.js",
  "nextjs",
  "react",
  "typescript",
  "javascript",
  "python",
  "c++",
  "cpp",
  "rust",
  "linux",
  "git",
  "github",
  "open source",
  "open source contributor",
  "web development",
  "creative coding",
  "software architecture",
  "high performance computing",
  "hpc",
  "rest api",
  "clean code",
  "system design",
  "turbopack",
  "shaders",
  "glitch art",
  "chromatic aberration",

  // Portfolio & Identity
  "portfolio",
  "personal website",
  "tech blog",
  "developer portfolio",
  "student portfolio",
  "engineering notes",
  "research logs",
  "developer blog",
  "independent researcher",
  "swift",
  "socrate",
  "skillab",
  "baddiesmash",
  "same curiosity different day",
  "learning in public"
];

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": "https://ihatebaselines.com/#website",
      "url": "https://ihatebaselines.com",
      "name": "ihatebaselines",
      "description":
        "Portfolio, notes and projects by Vlad Andrei Rus — AI architectures, machine learning, competitive programming, math, and building things from zero.",
      "publisher": {
        "@id": "https://ihatebaselines.com/#person"
      },
      "inLanguage": "en-US"
    },
    {
      "@type": "Person",
      "@id": "https://ihatebaselines.com/#person",
      "name": "Vlad Andrei Rus",
      "alternateName": [
        "Rus Vlad Andrei",
        "Vlad Andrei",
        "ihatebaselines",
        "vladandrei",
        "vladandreirus"
      ],
      "url": "https://ihatebaselines.com",
      "image": "https://ihatebaselines.com/images/ihatebaselines.jpg",
      "jobTitle": "Student Developer & AI Researcher",
      "worksFor": {
        "@type": "Organization",
        "name": "ihatebaselines"
      },
      "alumniOf": {
        "@type": "EducationalOrganization",
        "name": "Colegiul Național Emil Racoviță Cluj-Napoca"
      },
      "address": {
        "@type": "PostalAddress",
        "addressLocality": "Cluj-Napoca",
        "addressCountry": "RO"
      },
      "sameAs": [
        "https://github.com/ihatebaselines",
        "https://www.instagram.com/_rusuuu__",
        "https://www.linkedin.com/in/vladandreirus"
      ]
    },
    {
      "@type": "ImageObject",
      "@id": "https://ihatebaselines.com/#primaryimage",
      "inLanguage": "en-US",
      "url": "https://ihatebaselines.com/images/ihatebaselines.jpg",
      "contentUrl": "https://ihatebaselines.com/images/ihatebaselines.jpg",
      "width": 800,
      "height": 400,
      "caption": "ihatebaselines — Vlad Andrei Rus"
    }
  ]
};

export const metadata: Metadata = {
  metadataBase: new URL("https://ihatebaselines.com"),
  title: {
    default: "ihatebaselines. — Vlad Andrei Rus",
    template: "%s — ihatebaselines.",
  },
  description:
    "Portfolio, notes and projects by Vlad Andrei Rus — AI architectures, machine learning, competitive programming, math, and building things from zero.",
  applicationName: "ihatebaselines",
  authors: [{ name: "Vlad Andrei Rus", url: "https://ihatebaselines.com" }],
  generator: "Next.js",
  keywords: siteKeywords,
  referrer: "origin-when-cross-origin",
  creator: "Vlad Andrei Rus",
  publisher: "Vlad Andrei Rus",
  formatDetection: {
    telephone: false,
    date: false,
    address: false,
    email: false,
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  alternates: {
    canonical: "https://ihatebaselines.com",
    types: {
      "application/json+oembed": "https://ihatebaselines.com/api/oembed",
    },
  },
  openGraph: {
    title: "ihatebaselines. — Vlad Andrei Rus",
    description:
      "Portfolio, notes and projects by Vlad Andrei Rus — AI architectures, machine learning, competitive programming, math, and building things from zero.",
    url: "https://ihatebaselines.com",
    siteName: "ihatebaselines",
    locale: "en_US",
    type: "website",
    images: [
      {
        url: "https://ihatebaselines.com/images/ihatebaselines.jpg",
        secureUrl: "https://ihatebaselines.com/images/ihatebaselines.jpg",
        width: 800,
        height: 400,
        type: "image/jpeg",
        alt: "ihatebaselines — Vlad Andrei Rus",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ihatebaselines. — Vlad Andrei Rus",
    description:
      "Portfolio, notes and projects by Vlad Andrei Rus — AI architectures, machine learning, competitive programming, math.",
    site: "@ihatebaselines",
    creator: "@ihatebaselines",
    images: [
      {
        url: "https://ihatebaselines.com/images/ihatebaselines.jpg",
        alt: "ihatebaselines — Vlad Andrei Rus",
        width: 800,
        height: 400,
      },
    ],
  },
  icons: {
    icon: [
      { url: "/favicon.ico" },
      { url: "/icon.jpg", type: "image/jpeg" },
    ],
    apple: [
      { url: "/images/ihb_cropped.jpg" },
    ],
  },
  other: {
    "image": "https://ihatebaselines.com/images/ihatebaselines.jpg",
    "thumbnail": "https://ihatebaselines.com/images/ihatebaselines.jpg",
    "twitter:domain": "ihatebaselines.com",
    "twitter:url": "https://ihatebaselines.com",
    "twitter:label1": "Author",
    "twitter:data1": "Vlad Andrei Rus",
    "twitter:label2": "Field",
    "twitter:data2": "AI & Machine Learning",
    "msapplication-TileImage": "https://ihatebaselines.com/images/ihatebaselines.jpg",
    "msapplication-TileColor": "#000000",
    "pinterest-rich-pin": "true",
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
            __html: `(function(){try{var t=localStorage.getItem('ihb-theme')||'dark';document.documentElement.setAttribute('data-theme',t);}catch(e){document.documentElement.setAttribute('data-theme','dark');}})();`,
          }}
        />
        <meta name="theme-color" content="#0b0d0e" />
        <link rel="image_src" href="https://ihatebaselines.com/images/ihatebaselines.jpg" />
        <meta name="author" content="Vlad Andrei Rus" />
        <link
          rel="alternate"
          type="application/json+oembed"
          href="https://ihatebaselines.com/api/oembed"
          title="ihatebaselines"
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
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

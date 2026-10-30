import BlogSearch from "@/components/BlogSearch";
import { getSortedPosts } from "@/content/posts";
import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Blog — ihatebaselines",
  description: "Random thoughts, experiments, and things learned while building on the internet.",
};

export default function BlogIndexPage() {
  const posts = getSortedPosts();

  return (
    <main className="site-main">
      <PageIntro
        eyebrow="notes from the process"
        title="blog"
        description="Random thoughts, experiments, and things learned while building on the internet."
      />
      <BlogSearch posts={posts} />
    </main>
  );
}

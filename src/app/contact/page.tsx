import { PageIntro } from "@/components/SiteCards";

export const metadata = {
  title: "Contact — ihatebaselines",
  description: "Get in touch with Vlad about projects, ideas, or just to say hi.",
};

const socials = [
  { name: "GitHub", detail: "code and open source", href: "https://github.com/ihatebaselines" },
  { name: "LinkedIn", detail: "professional stuff", href: "https://www.linkedin.com/in/vladandreirus" },
  { name: "Discord", detail: "find me on Discord", href: "https://discordapp.com/users/934847546432581682" },
  { name: "Email", detail: "the direct route", href: "mailto:rusvlad1010@icloud.com" },
];

export default function ContactPage() {
  return (
    <main className="site-main">
      <PageIntro eyebrow="get in touch · 06" title="let’s talk" description="I’d love to hear from you — whether you have a question, an idea, a project, or just want to say hi. I’m always open to interesting conversations and collaborations." aside="good conversations start somewhere." />
      <section className="contact-panel">
        <div><small>email</small><h2>rusvlad1010@icloud.com</h2><p>Feel free to reach out anytime. I usually reply within a few days.</p></div>
        <a className="button button-primary" href="mailto:rusvlad1010@icloud.com">Send a message <span aria-hidden="true">→</span></a>
      </section>
      <section className="social-grid" aria-label="Other ways to connect">
        {socials.map((social) => <a className="social-card" href={social.href} key={social.name} target={social.href.startsWith("mailto:") ? undefined : "_blank"} rel={social.href.startsWith("mailto:") ? undefined : "noreferrer"}><span><strong>{social.name}</strong><small>{social.detail}</small></span><span aria-hidden="true">↗</span></a>)}
      </section>
      <section className="section-block"><hr className="section-divider" /><p className="page-description">Not sure what to say? “Hey” is a perfectly good start.</p></section>
    </main>
  );
}

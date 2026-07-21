"use client";

import { useState, useRef, useEffect } from "react";
import { createPortal } from "react-dom";
import styles from "@/app/page.module.css";

type Status = "idle" | "sending" | "sent" | "error";

export default function ContactModal({
  open,
  onClose,
}: {
  open: boolean;
  onClose: () => void;
}) {
  // ALL hooks at top level — no conditionals before hooks
  const [mounted, setMounted] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [status, setStatus] = useState<Status>("idle");
  const overlayRef = useRef<HTMLDivElement>(null);

  useEffect(() => { setMounted(true); }, []);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  // Lock body scroll when open
  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name || !email || !message) return;

    setStatus("sending");

    const subject = encodeURIComponent(`Portfolio contact from ${name}`);
    const body = encodeURIComponent(`Name: ${name}\nEmail: ${email}\n\n${message}`);
    const mailtoUrl = `mailto:rusvlad1010@icloud.com?subject=${subject}&body=${body}`;

    window.location.href = mailtoUrl;

    setTimeout(() => {
      setStatus("sent");
      setName("");
      setEmail("");
      setMessage("");
    }, 600);
  }

  // Don't render until mounted (avoids SSR/hydration mismatch) or when closed
  if (!mounted || !open) return null;

  return createPortal(
    <>
      {/* Backdrop */}
      <div
        ref={overlayRef}
        className={styles.contactBackdrop}
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Modal */}
      <div
        className={styles.contactModal}
        role="dialog"
        aria-modal="true"
        aria-label="Contact form"
      >
        <div className={styles.contactHeader}>
          <div>
            <p className={styles.contactKicker}>get in touch</p>
            <h2 className={styles.contactTitle}>say something :)</h2>
          </div>
          <button
            className={styles.contactClose}
            onClick={onClose}
            aria-label="Close"
            data-no-cat-drag
          >
            ✕
          </button>
        </div>

        {status === "sent" ? (
          <div className={styles.contactSuccess}>
            <img
              src="/images/pingu-noot.png"
              alt="Pingu celebrating"
              className={styles.contactSuccessPingu}
            />
            <p>noot noot! message sent :)</p>
            <button
              className={styles.projectButton}
              onClick={() => { setStatus("idle"); onClose(); }}
            >
              Close
            </button>
          </div>
        ) : (
          <form className={styles.contactForm} onSubmit={handleSubmit} noValidate>
            <div className={styles.contactRow}>
              <div className={styles.contactField}>
                <label htmlFor="contact-name">Name</label>
                <input
                  id="contact-name"
                  type="text"
                  placeholder="your name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  autoComplete="name"
                />
              </div>
              <div className={styles.contactField}>
                <label htmlFor="contact-email">Email</label>
                <input
                  id="contact-email"
                  type="email"
                  placeholder="your@email.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  autoComplete="email"
                />
              </div>
            </div>

            <div className={styles.contactField}>
              <label htmlFor="contact-message">Message</label>
              <textarea
                id="contact-message"
                placeholder="what's up?"
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                rows={5}
                required
              />
            </div>

            <button
              type="submit"
              className={styles.rawButton}
              disabled={status === "sending"}
              data-no-cat-drag
            >
              <span>{status === "sending" ? "sending..." : "Send it 🐧"}</span>
            </button>
          </form>
        )}
      </div>
    </>,
    document.body
  );
}

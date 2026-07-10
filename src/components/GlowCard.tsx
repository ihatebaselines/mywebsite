"use client";

import { useRef, useState } from "react";
import styles from "@/app/page.module.css";

export default function GlowCard({
  children,
  className = "",
  as: Tag = "div",
  ...rest
}: {
  children: React.ReactNode;
  className?: string;
  as?: "div" | "article" | "a";
} & React.HTMLAttributes<HTMLElement>) {
  const cardRef = useRef<any>(null);
  const [pointer, setPointer] = useState({ x: 50, y: 50 });
  const [hovering, setHovering] = useState(false);

  function handleMouseMove(event: React.MouseEvent) {
    const rect = cardRef.current?.getBoundingClientRect();
    if (!rect) return;
    setPointer({
      x: ((event.clientX - rect.left) / rect.width) * 100,
      y: ((event.clientY - rect.top) / rect.height) * 100,
    });
  }

  return (
    <Tag
      ref={cardRef}
      className={`${styles.glowCard} ${className}`}
      onMouseMove={handleMouseMove}
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      style={
        {
          "--glow-x": `${pointer.x}%`,
          "--glow-y": `${pointer.y}%`,
          "--glow-opacity": hovering ? 1 : 0,
        } as React.CSSProperties
      }
      {...rest}
    >
      {children}
    </Tag>
  );
}

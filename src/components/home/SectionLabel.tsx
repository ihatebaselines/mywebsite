import React from "react";
import styles from "@/app/page.module.css";

interface SectionLabelProps {
  label: string; // e.g. "01 / PROJECTS"
  className?: string;
}

export default function SectionLabel({ label, className }: SectionLabelProps) {
  return (
    <div className={`${styles.sectionLabelRoot} ${className || ""}`}>
      <span className={styles.sectionLabelText}>{label}</span>
    </div>
  );
}

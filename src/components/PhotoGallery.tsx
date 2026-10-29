"use client";

import React, { useState, useEffect, useCallback, useRef } from "react";
import {
  ChevronLeft,
  ChevronRight,
  X,
  Maximize2,
  Minimize2,
  ZoomIn,
  ZoomOut,
  Sparkles,
} from "lucide-react";
import styles from "@/app/page.module.css";

interface PhotoGalleryProps {
  images: string[];
  title?: string;
}

export default function PhotoGallery({ images, title = "Event Gallery" }: PhotoGalleryProps) {
  const [lightboxIndex, setLightboxIndex] = useState<number | null>(null);
  const [isZoomed, setIsZoomed] = useState<boolean>(false);
  const [isFullscreen, setIsFullscreen] = useState<boolean>(false);

  const lightboxRef = useRef<HTMLDivElement>(null);
  const thumbStripRef = useRef<HTMLDivElement>(null);

  // Close or navigate with keyboard
  useEffect(() => {
    if (lightboxIndex === null) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setLightboxIndex(null);
        setIsZoomed(false);
      } else if (e.key === "ArrowRight") {
        setLightboxIndex((prev) => (prev !== null ? (prev + 1) % images.length : 0));
        setIsZoomed(false);
      } else if (e.key === "ArrowLeft") {
        setLightboxIndex((prev) =>
          prev !== null ? (prev - 1 + images.length) % images.length : images.length - 1
        );
        setIsZoomed(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    document.body.style.overflow = "hidden";

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "";
    };
  }, [lightboxIndex, images.length]);

  // Center thumbnail in lightbox strip when index changes
  useEffect(() => {
    if (lightboxIndex !== null && thumbStripRef.current) {
      const activeThumb = thumbStripRef.current.children[lightboxIndex] as HTMLElement;
      if (activeThumb) {
        activeThumb.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
      }
    }
  }, [lightboxIndex]);

  const openLightbox = useCallback((index: number) => {
    setLightboxIndex(index);
    setIsZoomed(false);
  }, []);

  const nextImage = useCallback(
    (e?: React.MouseEvent) => {
      e?.stopPropagation();
      setLightboxIndex((prev) => (prev !== null ? (prev + 1) % images.length : 0));
      setIsZoomed(false);
    },
    [images.length]
  );

  const prevImage = useCallback(
    (e?: React.MouseEvent) => {
      e?.stopPropagation();
      setLightboxIndex((prev) =>
        prev !== null ? (prev - 1 + images.length) % images.length : images.length - 1
      );
      setIsZoomed(false);
    },
    [images.length]
  );

  // Fullscreen toggler
  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      lightboxRef.current?.requestFullscreen().catch(() => {});
      setIsFullscreen(true);
    } else {
      document.exitFullscreen().catch(() => {});
      setIsFullscreen(false);
    }
  };

  if (!images || images.length === 0) return null;

  // Facebook collage layout logic
  // Max 5 preview slots: slot 0 (large featured), slots 1, 2, 3, 4
  const previewLimit = 5;
  const showCollage = images.slice(0, previewLimit);
  const remainingCount = images.length - previewLimit;

  return (
    <div className={styles.galleryWrapper}>
      {/* Gallery Header */}
      <div className={styles.galleryHeaderRow}>
        <div className={styles.sectionHeader} style={{ margin: 0 }}>
          <p>Event Gallery</p>
          <h2 className={styles.resourceSectionTitle}>
            {title} <span className={styles.galleryCountBadge}>({images.length} photos)</span>
          </h2>
        </div>
      </div>

      {/* ─── FACEBOOK COLLAGE / MOSAIC VIEW ONLY ─── */}
      <div
        className={`${styles.fbCollageGrid} ${
          images.length === 1
            ? styles.fbCollage1
            : images.length === 2
            ? styles.fbCollage2
            : images.length === 3
            ? styles.fbCollage3
            : images.length === 4
            ? styles.fbCollage4
            : styles.fbCollage5
        }`}
      >
        {showCollage.map((imgSrc, idx) => {
          const isLast = idx === previewLimit - 1 && remainingCount > 0;
          return (
            <div
              key={idx}
              className={`${styles.fbCollageItem} ${styles[`fbItem${idx}`] || ""}`}
              onClick={() => openLightbox(idx)}
            >
              <img
                src={imgSrc}
                alt={`Photo ${idx + 1}`}
                loading="lazy"
                decoding="async"
                className={styles.fbCollageImg}
              />
              <div className={styles.fbCollageHoverOverlay}>
                <Maximize2 size={22} className={styles.fbHoverIcon} />
              </div>

              {isLast && (
                <div className={styles.fbMoreOverlay}>
                  <div className={styles.fbMoreContent}>
                    <span className={styles.fbMoreNumber}>+{remainingCount}</span>
                    <span className={styles.fbMoreLabel}>view all photos</span>
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* ─── FULLSCREEN INTERACTIVE LIGHTBOX MODAL ─── */}
      {lightboxIndex !== null && (
        <div
          className={styles.lightboxModal}
          ref={lightboxRef}
          role="dialog"
          aria-modal="true"
          onClick={() => {
            setLightboxIndex(null);
            setIsZoomed(false);
          }}
        >
          {/* Ambient Glow Backdrop */}
          <img
            src={images[lightboxIndex]}
            alt=""
            aria-hidden="true"
            className={styles.lightboxGlowBg}
          />
          <div className={styles.lightboxBackdropTint} />

          {/* Top Bar Controls */}
          <div className={styles.lightboxTopBar} onClick={(e) => e.stopPropagation()}>
            <div className={styles.lightboxCounterWrap}>
              <Sparkles size={16} className={styles.lightboxSparkle} />
              <span className={styles.lightboxCounter}>
                <strong>{String(lightboxIndex + 1).padStart(2, "0")}</strong> / {String(images.length).padStart(2, "0")}
              </span>
            </div>

            <div className={styles.lightboxActionGroup}>
              <button
                type="button"
                className={styles.lightboxIconBtn}
                onClick={() => setIsZoomed((prev) => !prev)}
                title={isZoomed ? "Zoom Out" : "Zoom In"}
              >
                {isZoomed ? <ZoomOut size={18} /> : <ZoomIn size={18} />}
              </button>
              <button
                type="button"
                className={styles.lightboxIconBtn}
                onClick={toggleFullscreen}
                title={isFullscreen ? "Exit Fullscreen" : "Fullscreen"}
              >
                {isFullscreen ? <Minimize2 size={18} /> : <Maximize2 size={18} />}
              </button>
              <button
                type="button"
                className={`${styles.lightboxIconBtn} ${styles.lightboxCloseBtn}`}
                onClick={() => {
                  setLightboxIndex(null);
                  setIsZoomed(false);
                }}
                title="Close (Esc)"
              >
                <X size={20} />
              </button>
            </div>
          </div>

          {/* Main Display Stage */}
          <div className={styles.lightboxStage} onClick={(e) => e.stopPropagation()}>
            <button
              type="button"
              className={`${styles.lightboxNavBtn} ${styles.lightboxNavPrev}`}
              onClick={prevImage}
              aria-label="Previous photo"
            >
              <ChevronLeft size={28} />
            </button>

            <div
              className={`${styles.lightboxImageWrap} ${isZoomed ? styles.lightboxImageZoomed : ""}`}
              onClick={() => setIsZoomed((prev) => !prev)}
            >
              <img
                key={lightboxIndex}
                src={images[lightboxIndex]}
                alt={`Photo ${lightboxIndex + 1}`}
                className={styles.lightboxMainImg}
              />
            </div>

            <button
              type="button"
              className={`${styles.lightboxNavBtn} ${styles.lightboxNavNext}`}
              onClick={nextImage}
              aria-label="Next photo"
            >
              <ChevronRight size={28} />
            </button>
          </div>

          {/* Bottom Thumbnail Strip Carousel */}
          <div className={styles.lightboxThumbStripWrap} onClick={(e) => e.stopPropagation()}>
            <div className={styles.lightboxThumbStrip} ref={thumbStripRef}>
              {images.map((imgSrc, idx) => (
                <button
                  key={idx}
                  type="button"
                  className={`${styles.lightboxThumbItem} ${
                    idx === lightboxIndex ? styles.lightboxThumbActive : ""
                  }`}
                  onClick={() => {
                    setLightboxIndex(idx);
                    setIsZoomed(false);
                  }}
                  aria-label={`View photo ${idx + 1}`}
                >
                  <img src={imgSrc} alt={`Thumb ${idx + 1}`} />
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

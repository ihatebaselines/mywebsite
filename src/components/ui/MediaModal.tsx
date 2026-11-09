'use client';

import React, { useEffect, useState, useRef } from 'react';
import Image from 'next/image';
import { AnimatePresence, motion } from 'motion/react';
import { X, ChevronLeft, ChevronRight, ZoomIn } from 'lucide-react';

export type MediaItem = {
  id?: string;
  url: string;
  title?: string;
  caption?: string;
  type?: 'image' | 'video';
};

export type MediaModalProps = {
  items?: MediaItem[];
  initialIndex?: number;
  isOpen: boolean;
  onClose: () => void;
};

export const MediaModal: React.FC<MediaModalProps> = ({
  items = [],
  initialIndex = 0,
  isOpen,
  onClose,
}) => {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const carouselRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setCurrentIndex(initialIndex);
  }, [initialIndex]);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowRight') nextItem();
      if (e.key === 'ArrowLeft') prevItem();
    };

    if (isOpen) {
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      document.body.style.overflow = '';
    };
  }, [isOpen, items.length, currentIndex]);

  const currentItem = items[currentIndex];

  const nextItem = () => {
    if (items.length <= 1) return;
    setCurrentIndex((prev) => (prev + 1) % items.length);
  };

  const prevItem = () => {
    if (items.length <= 1) return;
    setCurrentIndex((prev) => (prev - 1 + items.length) % items.length);
  };

  if (!isOpen || !currentItem) return null;

  return (
    <AnimatePresence>
      <motion.div
        className="media-modal-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
        onClick={onClose}
        role="dialog"
        aria-modal="true"
        aria-label="Image Preview"
      >
        {/* Top Controls Bar */}
        <div className="media-modal-topbar" onClick={(e) => e.stopPropagation()}>
          <div className="media-modal-counter">
            {items.length > 1 ? (
              <span>
                {currentIndex + 1} / {items.length}
              </span>
            ) : null}
            {currentItem.title ? <strong className="media-modal-title">{currentItem.title}</strong> : null}
          </div>

          <button
            type="button"
            className="media-modal-close"
            onClick={onClose}
            aria-label="Close lightbox"
          >
            <X size={20} />
          </button>
        </div>

        {/* Navigation Arrows */}
        {items.length > 1 ? (
          <>
            <button
              type="button"
              className="media-modal-nav prev"
              onClick={(e) => {
                e.stopPropagation();
                prevItem();
              }}
              aria-label="Previous image"
            >
              <ChevronLeft size={28} />
            </button>
            <button
              type="button"
              className="media-modal-nav next"
              onClick={(e) => {
                e.stopPropagation();
                nextItem();
              }}
              aria-label="Next image"
            >
              <ChevronRight size={28} />
            </button>
          </>
        ) : null}

        {/* Center Stage Preview */}
        <motion.div
          key={currentItem.url}
          className="media-modal-stage"
          initial={{ opacity: 0, scale: 0.94 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.94 }}
          transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
        >
          {currentItem.type === 'video' || currentItem.url.endsWith('.mp4') ? (
            <video
              src={currentItem.url}
              controls
              autoPlay
              className="media-modal-main-video"
            />
          ) : (
            <div className="media-modal-img-wrap">
              <Image
                src={currentItem.url}
                alt={currentItem.title || 'Lightbox preview'}
                width={1280}
                height={850}
                className="media-modal-main-img"
                priority
              />
            </div>
          )}

          {currentItem.caption ? (
            <p className="media-modal-caption">{currentItem.caption}</p>
          ) : null}
        </motion.div>

        {/* Thumbnail Carousel Slider (when multiple items exist) */}
        {items.length > 1 ? (
          <div
            ref={carouselRef}
            className="media-modal-thumbs"
            onClick={(e) => e.stopPropagation()}
          >
            {items.map((item, idx) => (
              <button
                key={`${item.url}-${idx}`}
                type="button"
                className={`media-modal-thumb-btn ${idx === currentIndex ? 'active' : ''}`}
                onClick={() => setCurrentIndex(idx)}
              >
                <Image
                  src={item.url}
                  alt={item.title || `Thumbnail ${idx + 1}`}
                  width={80}
                  height={56}
                  className="media-modal-thumb-img"
                />
              </button>
            ))}
          </div>
        ) : null}
      </motion.div>
    </AnimatePresence>
  );
};

export type ClickableImageProps = {
  src: string;
  alt: string;
  title?: string;
  caption?: string;
  className?: string;
  width?: number;
  height?: number;
  galleryItems?: MediaItem[];
  itemIndex?: number;
};

export const ClickableImage: React.FC<ClickableImageProps> = ({
  src,
  alt,
  title,
  caption,
  className = '',
  width = 600,
  height = 400,
  galleryItems,
  itemIndex = 0,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const items = galleryItems && galleryItems.length > 0
    ? galleryItems
    : [{ url: src, title: title || alt, caption }];

  return (
    <>
      <div
        className={`clickable-image-trigger group ${className}`}
        onClick={() => setIsOpen(true)}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            setIsOpen(true);
          }
        }}
        title="Click to zoom image"
      >
        <Image
          src={src}
          alt={alt}
          width={width}
          height={height}
          className="clickable-image-img"
        />
        <div className="clickable-image-badge" aria-hidden="true">
          <ZoomIn size={14} />
          <span>zoom</span>
        </div>
      </div>

      <MediaModal
        items={items}
        initialIndex={itemIndex}
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
      />
    </>
  );
};

export default MediaModal;

'use client';

import React from 'react';
import Link from 'next/link';
import Image from 'next/image';

export type StackingCardItem = {
  id?: string;
  number?: string;
  title: string;
  tag: string;
  description: string;
  meta?: string;
  image?: string;
  href?: string;
  tags?: string[];
  external?: boolean;
};

export const DEFAULT_STACK_CARDS: StackingCardItem[] = [
  {
    id: 'swiftfox',
    number: '01',
    title: 'swiftfox',
    tag: 'SYSTEMS & AI',
    description:
      'High-performance neural execution engine & systems optimization framework written from first principles.',
    meta: 'OCT 2026',
    image: '/images/swiftfox.png',
    href: '/projects/swift',
    tags: ['C++', 'CUDA', 'Python', 'Neural Engine'],
  },
  {
    id: 'socratex',
    number: '02',
    title: 'socratex',
    tag: 'REASONING & LLMS',
    description:
      'Reasoning-first architecture exploring tree-of-thought verification, self-critique, and mathematical problem solving.',
    meta: 'JUL 2026',
    image: '/images/socrate-logo.png',
    href: '/projects/socrate-main-model',
    tags: ['PyTorch', 'Transformers', 'RLHF', 'Reasoning'],
  },
  {
    id: 'skillab-radar',
    number: '03',
    title: 'skillab radar',
    tag: 'ANALYTICS & AUTOMATION',
    description:
      'Real-time market intelligence & skills telemetry tracking tech trends and automated qualification benchmarks.',
    meta: 'JUN 2026',
    image: '/images/skillab-logo-img.jpg',
    href: '/projects/skillab-radar',
    tags: ['TypeScript', 'Next.js', 'PostgreSQL', 'Scrapers'],
  },
  {
    id: 'dpit-2026',
    number: '04',
    title: 'dpit 2026 first prize',
    tag: 'COMPETITION',
    description:
      '1st Place at Descoperă-ți Pasiunea în IT — automated end-to-end multi-agent system solving real-world workflows.',
    meta: 'NOV 2026',
    image: '/images/dpit-award.jpg',
    href: '/work/dpit-2026',
    tags: ['National Award', '1st Place', 'Agents', 'Full-Stack'],
  },
];

export type StackingCardsProps = {
  cards?: StackingCardItem[];
  className?: string;
  topOffset?: number;
  stepOffset?: number;
};

export const StackingCards: React.FC<StackingCardsProps> = ({
  cards = DEFAULT_STACK_CARDS,
  className = '',
  topOffset = 72,
  stepOffset = 24,
}) => {
  return (
    <div className={`stacking-cards-container ${className}`}>
      {cards.map((card, index) => {
        const stickyTop = topOffset + index * stepOffset;
        const cardNumber = card.number || String(index + 1).padStart(2, '0');

        return (
          <div
            key={card.id || card.title}
            className="stacking-card-item"
            style={{
              top: `${stickyTop}px`,
              zIndex: 10 + index,
            }}
          >
            <div className="stacking-card-inner">
              {/* Header: Number & Tag */}
              <div className="stacking-card-header">
                <div className="stacking-card-meta-left">
                  <span className="stacking-card-number">{cardNumber}</span>
                  <span className="stacking-card-tag">{card.tag}</span>
                </div>
                {card.meta ? (
                  <span className="stacking-card-date">{card.meta}</span>
                ) : null}
              </div>

              {/* Main Content Body */}
              <div className="stacking-card-body">
                <div className="stacking-card-details">
                  <h3 className="stacking-card-title">{card.title}</h3>
                  <p className="stacking-card-desc">{card.description}</p>

                  {card.tags && card.tags.length > 0 ? (
                    <div className="stacking-card-tags">
                      {card.tags.map((tag) => (
                        <span key={tag} className="stacking-card-tag-pill">
                          {tag}
                        </span>
                      ))}
                    </div>
                  ) : null}

                  {card.href ? (
                    <div className="stacking-card-action">
                      {card.external ? (
                        <a
                          href={card.href}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="stacking-card-link"
                        >
                          view project <span aria-hidden="true">↗</span>
                        </a>
                      ) : (
                        <Link href={card.href} className="stacking-card-link">
                          explore project <span aria-hidden="true">→</span>
                        </Link>
                      )}
                    </div>
                  ) : null}
                </div>

                {/* Visual / Image Media */}
                {card.image ? (
                  <div className="stacking-card-media">
                    <Image
                      src={card.image}
                      alt={card.title}
                      width={480}
                      height={320}
                      className="stacking-card-img"
                    />
                  </div>
                ) : null}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default StackingCards;

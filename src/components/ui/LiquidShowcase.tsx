'use client';

import React, { useState } from 'react';
import { LiquidButton } from './LiquidButton';
import { PALETTES } from './liquid-gradient';

export function LiquidShowcase() {
  const [activePalette, setActivePalette] = useState<'cyberEmerald' | 'matrixMint' | 'monochrome'>('cyberEmerald');

  const paletteNames = [
    { key: 'cyberEmerald', name: 'Cyber Emerald', desc: 'Black + White + Neon Emerald' },
    { key: 'matrixMint', name: 'Matrix Mint', desc: 'Obsidian + Bright Mint' },
    { key: 'monochrome', name: 'Monochrome Stealth', desc: 'Pure Stark Black & White' },
  ] as const;

  return (
    <div className="liquid-showcase-box">
      <div className="liquid-palette-tabs" role="tablist">
        {paletteNames.map(({ key, name }) => (
          <button
            key={key}
            type="button"
            role="tab"
            aria-selected={activePalette === key}
            className={`liquid-palette-tab ${activePalette === key ? 'active' : ''}`}
            onClick={() => setActivePalette(key)}
          >
            {name}
          </button>
        ))}
      </div>

      <div className="liquid-demo-stage">
        <LiquidButton
          palette={activePalette}
          label="github"
          sublabel="github.com/ihatebaselines"
          href="https://github.com/ihatebaselines"
        />

        <LiquidButton
          palette={activePalette}
          label="explore work"
          sublabel="competitions & projects"
          href="/work"
          showStar={false}
        />
      </div>

      <p className="liquid-palette-caption">
        Active Palette: <strong>{paletteNames.find(p => p.key === activePalette)?.desc}</strong>
      </p>
    </div>
  );
}

export default LiquidShowcase;

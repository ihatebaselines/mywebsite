'use client';

import React from 'react';
import { AnimatePresence, motion } from 'motion/react';

export type ColorKey =
  | 'color1'
  | 'color2'
  | 'color3'
  | 'color4'
  | 'color5'
  | 'color6'
  | 'color7'
  | 'color8'
  | 'color9'
  | 'color10'
  | 'color11'
  | 'color12'
  | 'color13'
  | 'color14'
  | 'color15'
  | 'color16'
  | 'color17';

export type Colors = Record<ColorKey, string>;

/**
 * Brand Palettes: Black, White, and Emerald/Teal/Green
 */
export const PALETTES = {
  // Primary brand palette: Deep obsidian black, crisp white, and glowing emerald/cyan
  cyberEmerald: {
    color1: '#FFFFFF',
    color2: '#059669', // Emerald
    color3: '#34D399', // Mint highlight
    color4: '#F0FDF4', // Off-white
    color5: '#E6FFFA', // Cyan tint
    color6: '#4A9390', // Brand accent
    color7: '#064E3B', // Deep forest
    color8: '#10B981', // Neon emerald
    color9: '#0F766E', // Dark teal
    color10: '#2DD4BF', // Bright teal
    color11: '#042F2E', // Midnight teal
    color12: '#6EE7B7', // Soft mint
    color13: '#022C22', // Deepest green-black
    color14: '#A7F3D0', // Pale mint
    color15: '#5CB0AC', // Accent dark
    color16: '#0B0C0E', // Site background
    color17: '#1B4332', // Hunter green
  } satisfies Colors,

  // Electric Matrix: High-voltage mint and deep abyss
  matrixMint: {
    color1: '#FFFFFF',
    color2: '#10B981',
    color3: '#6EE7B7',
    color4: '#F9FBF9',
    color5: '#ECFDF5',
    color6: '#34D399',
    color7: '#047857',
    color8: '#059669',
    color9: '#10B981',
    color10: '#A7F3D0',
    color11: '#064E3B',
    color12: '#D1FAE5',
    color13: '#022C22',
    color14: '#6EE7B7',
    color15: '#A7F3D0',
    color16: '#021814',
    color17: '#0D9488',
  } satisfies Colors,

  // Minimalist Monochrome: Pure stark blacks and whites
  monochrome: {
    color1: '#FFFFFF',
    color2: '#27272A',
    color3: '#A1A1AA',
    color4: '#FAFAFA',
    color5: '#F4F4F5',
    color6: '#71717A',
    color7: '#18181B',
    color8: '#09090B',
    color9: '#3F3F46',
    color10: '#D4D4D8',
    color11: '#000000',
    color12: '#E4E4E7',
    color13: '#0B0C0E',
    color14: '#F4F4F5',
    color15: '#A1A1AA',
    color16: '#101215',
    color17: '#52525B',
  } satisfies Colors,
};

const svgOrder = ['svg1', 'svg2', 'svg3', 'svg4', 'svg3', 'svg2', 'svg1'] as const;
type SvgKey = (typeof svgOrder)[number];

type Stop = {
  offset: number;
  stopColor: string;
};

type SvgState = {
  gradientTransform: string;
  stops: Stop[];
};

type SvgStates = Record<SvgKey, SvgState>;

const createStopsArray = (
  svgStates: SvgStates,
  order: readonly SvgKey[],
  maxStops: number
): Stop[][] => {
  const stopsArray: Stop[][] = [];
  for (let i = 0; i < maxStops; i++) {
    const stopConfigurations = order.map((svgKey) => {
      const svg = svgStates[svgKey];
      return svg.stops[i] || svg.stops[svg.stops.length - 1];
    });
    stopsArray.push(stopConfigurations);
  }
  return stopsArray;
};

type GradientSvgProps = {
  className?: string;
  isHovered: boolean;
  colors: Colors;
  idPrefix?: string;
};

const GradientSvg: React.FC<GradientSvgProps> = ({
  className = '',
  isHovered,
  colors,
  idPrefix = 'liq',
}) => {
  const svgStates: SvgStates = {
    svg1: {
      gradientTransform: 'translate(287.5 280) rotate(-29.0546) scale(689.807 1000)',
      stops: [
        { offset: 0, stopColor: colors.color1 },
        { offset: 0.188423, stopColor: colors.color2 },
        { offset: 0.260417, stopColor: colors.color3 },
        { offset: 0.328792, stopColor: colors.color4 },
        { offset: 0.328892, stopColor: colors.color5 },
        { offset: 0.328992, stopColor: colors.color1 },
        { offset: 0.442708, stopColor: colors.color6 },
        { offset: 0.537556, stopColor: colors.color7 },
        { offset: 0.631738, stopColor: colors.color1 },
        { offset: 0.725645, stopColor: colors.color8 },
        { offset: 0.817779, stopColor: colors.color9 },
        { offset: 0.84375, stopColor: colors.color10 },
        { offset: 0.90569, stopColor: colors.color1 },
        { offset: 1, stopColor: colors.color11 },
      ],
    },
    svg2: {
      gradientTransform: 'translate(126.5 418.5) rotate(-64.756) scale(533.444 773.324)',
      stops: [
        { offset: 0, stopColor: colors.color1 },
        { offset: 0.104167, stopColor: colors.color12 },
        { offset: 0.182292, stopColor: colors.color13 },
        { offset: 0.28125, stopColor: colors.color1 },
        { offset: 0.328792, stopColor: colors.color4 },
        { offset: 0.328892, stopColor: colors.color5 },
        { offset: 0.453125, stopColor: colors.color6 },
        { offset: 0.515625, stopColor: colors.color7 },
        { offset: 0.631738, stopColor: colors.color1 },
        { offset: 0.692708, stopColor: colors.color8 },
        { offset: 0.75, stopColor: colors.color14 },
        { offset: 0.817708, stopColor: colors.color9 },
        { offset: 0.869792, stopColor: colors.color10 },
        { offset: 1, stopColor: colors.color1 },
      ],
    },
    svg3: {
      gradientTransform: 'translate(264.5 339.5) rotate(-42.3022) scale(946.451 1372.05)',
      stops: [
        { offset: 0, stopColor: colors.color1 },
        { offset: 0.188423, stopColor: colors.color2 },
        { offset: 0.307292, stopColor: colors.color1 },
        { offset: 0.328792, stopColor: colors.color4 },
        { offset: 0.328892, stopColor: colors.color5 },
        { offset: 0.442708, stopColor: colors.color15 },
        { offset: 0.537556, stopColor: colors.color16 },
        { offset: 0.631738, stopColor: colors.color1 },
        { offset: 0.725645, stopColor: colors.color17 },
        { offset: 0.817779, stopColor: colors.color9 },
        { offset: 0.84375, stopColor: colors.color10 },
        { offset: 0.90569, stopColor: colors.color1 },
        { offset: 1, stopColor: colors.color11 },
      ],
    },
    svg4: {
      gradientTransform: 'translate(860.5 420) rotate(-153.984) scale(957.528 1388.11)',
      stops: [
        { offset: 0.109375, stopColor: colors.color11 },
        { offset: 0.171875, stopColor: colors.color2 },
        { offset: 0.260417, stopColor: colors.color13 },
        { offset: 0.328792, stopColor: colors.color4 },
        { offset: 0.328892, stopColor: colors.color5 },
        { offset: 0.328992, stopColor: colors.color1 },
        { offset: 0.442708, stopColor: colors.color6 },
        { offset: 0.515625, stopColor: colors.color7 },
        { offset: 0.631738, stopColor: colors.color1 },
        { offset: 0.692708, stopColor: colors.color8 },
        { offset: 0.817708, stopColor: colors.color9 },
        { offset: 0.869792, stopColor: colors.color10 },
        { offset: 1, stopColor: colors.color11 },
      ],
    },
  };

  const maxStops = Math.max(...Object.values(svgStates).map((svg) => svg.stops.length));
  const stopsAnimationArray = createStopsArray(svgStates, svgOrder, maxStops);
  const gradientTransform = svgOrder.map((svgKey) => svgStates[svgKey].gradientTransform);

  const gradientId = `${idPrefix}_radial`;

  const variants = {
    hovered: {
      gradientTransform,
      transition: { duration: 15, repeat: Number.POSITIVE_INFINITY, ease: 'linear' as const },
    },
    notHovered: {
      gradientTransform,
      transition: { duration: 30, repeat: Number.POSITIVE_INFINITY, ease: 'linear' as const },
    },
  };

  return (
    <svg
      className={className}
      width="1030"
      height="280"
      viewBox="0 0 1030 280"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect width="1030" height="280" rx="140" fill={`url(#${gradientId})`} />
      <defs>
        <motion.radialGradient
          id={gradientId}
          cx="0"
          cy="0"
          r="1"
          gradientUnits="userSpaceOnUse"
          animate={isHovered ? variants.hovered : variants.notHovered}
        >
          {stopsAnimationArray.map((stopConfigs, index) => (
            <AnimatePresence key={index}>
              <motion.stop
                initial={{
                  offset: stopConfigs[0].offset,
                  stopColor: stopConfigs[0].stopColor,
                }}
                animate={{
                  offset: stopConfigs.map((config) => config.offset),
                  stopColor: stopConfigs.map((config) => config.stopColor),
                }}
                transition={{
                  duration: 0,
                  ease: 'linear',
                  repeat: Number.POSITIVE_INFINITY,
                }}
              />
            </AnimatePresence>
          ))}
        </motion.radialGradient>
      </defs>
    </svg>
  );
};

export type LiquidProps = {
  isHovered: boolean;
  colors?: Colors;
  buttonType?: boolean;
  idPrefix?: string;
};

export const Liquid: React.FC<LiquidProps> = ({
  isHovered,
  colors = PALETTES.cyberEmerald,
  buttonType = false,
  idPrefix = 'liq',
}) => {
  return (
    <>
      {Array.from({ length: 7 }).map((_, index) => (
        <div
          key={index}
          className={`absolute ${index < 3 ? 'w-[443px] h-[121px]' : 'w-[756px] h-[207px]'} ${
            index === 0
              ? 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 mix-blend-difference'
              : index === 1
                ? 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rotate-[164.971deg] mix-blend-difference'
                : index === 2
                  ? 'top-1/2 left-1/2 -translate-x-[53%] -translate-y-[53%] rotate-[-11.61deg] mix-blend-difference'
                  : index === 3
                    ? 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-[57%] rotate-[-179.012deg] mix-blend-difference'
                    : index === 4
                      ? 'top-1/2 left-1/2 -translate-x-[57%] -translate-y-1/2 rotate-[-29.722deg] mix-blend-difference'
                      : index === 5
                        ? 'top-1/2 left-1/2 -translate-x-[62%] -translate-y-[24%] rotate-[160.227deg] mix-blend-difference'
                        : 'top-1/2 left-1/2 -translate-x-[67%] -translate-y-[29%] rotate-180 mix-blend-hard-light'
          }`}
          style={{ pointerEvents: 'none' }}
        >
          <GradientSvg
            className="w-full h-full"
            isHovered={isHovered}
            colors={colors}
            idPrefix={`${idPrefix}_${index}`}
          />
        </div>
      ))}
    </>
  );
};

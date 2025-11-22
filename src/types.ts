import { BrowserWindow } from 'electron';

export type VibrancyMaterial =
  | 'titlebar'
  | 'sidebar'
  | 'menu'
  | 'popover'
  | 'hudWindow'
  | 'sheet'
  | 'tooltip'
  | 'underWindowBackground';

export type BlendingMode = 'behindWindow' | 'withinWindow';

export type VibrancyState = 'active' | 'inactive' | 'followsWindowActiveState';

export interface AutoresizingMask {
  width?: boolean;
  height?: boolean;
  minX?: boolean;
  maxX?: boolean;
  minY?: boolean;
  maxY?: boolean;
}

export interface VibrancyViewOptions {
  /**
   * X position of the vibrancy view
   * @default 0
   */
  x?: number;

  /**
   * Y position of the vibrancy view
   * @default 0
   */
  y?: number;

  /**
   * Width of the vibrancy view
   * @default 200
   */
  width?: number;

  /**
   * Height of the vibrancy view
   * @default window height
   */
  height?: number;

  /**
   * Material type for the vibrancy effect
   * @default 'sidebar'
   */
  material?: VibrancyMaterial;

  /**
   * Blending mode for the effect
   * @default 'behindWindow'
   */
  blendingMode?: BlendingMode;

  /**
   * Active state behavior
   * @default 'followsWindowActiveState'
   */
  state?: VibrancyState;

  /**
   * Corner radius for the vibrancy view
   * @default 0
   */
  cornerRadius?: number;

  /**
   * Autoresizing mask options
   */
  autoresizingMask?: AutoresizingMask;
}

export interface RGBColor {
  r: number;
  g: number;
  b: number;
  a?: number;
}

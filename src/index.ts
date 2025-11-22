import { BrowserWindow } from 'electron';
import { VibrancyViewOptions, RGBColor } from './types';

// Load native module
const native = require('../build/Release/electrolyx.node');

/**
 * Get the native window handle from an Electron BrowserWindow
 */
function getWindowHandle(window: BrowserWindow): Buffer {
  const handle = window.getNativeWindowHandle();
  return handle;
}

/**
 * Set custom corner radius for a window using private macOS APIs
 *
 * WARNING: This uses undocumented private APIs and may break in future macOS versions
 *
 * @param window - Electron BrowserWindow instance
 * @param radius - Corner radius in points
 * @returns true if successful, false otherwise
 */
export function setWindowCornerRadius(window: BrowserWindow, radius: number): boolean {
  try {
    const handle = getWindowHandle(window);
    return native.setWindowCornerRadius(handle, radius);
  } catch (error) {
    console.error('Failed to set window corner radius:', error);
    return false;
  }
}

/**
 * Get the current corner radius of a window
 *
 * @param window - Electron BrowserWindow instance
 * @returns Current corner radius in points
 */
export function getWindowCornerRadius(window: BrowserWindow): number {
  try {
    const handle = getWindowHandle(window);
    return native.getWindowCornerRadius(handle);
  } catch (error) {
    console.error('Failed to get window corner radius:', error);
    return 0;
  }
}

/**
 * Add a vibrancy (blur/glass) effect view to a window using public NSVisualEffectView API
 *
 * This creates a native macOS visual effect view with blur and translucency.
 * Perfect for sidebars, toolbars, or any UI element that needs the native glass effect.
 *
 * @param window - Electron BrowserWindow instance
 * @param options - Configuration options for the vibrancy view
 * @returns true if successful, false otherwise
 */
export function addVibrancyView(window: BrowserWindow, options: VibrancyViewOptions = {}): boolean {
  try {
    const handle = getWindowHandle(window);
    return native.addVibrancyView(handle, options);
  } catch (error) {
    console.error('Failed to add vibrancy view:', error);
    return false;
  }
}

/**
 * Set the background color of a window
 *
 * @param window - Electron BrowserWindow instance
 * @param color - RGB color object with values from 0-1
 */
export function setWindowBackgroundColor(window: BrowserWindow, color: RGBColor): boolean {
  try {
    const handle = getWindowHandle(window);
    const { r, g, b, a = 1.0 } = color;
    return native.setWindowBackgroundColor(handle, r, g, b, a);
  } catch (error) {
    console.error('Failed to set window background color:', error);
    return false;
  }
}

/**
 * Make a window background completely transparent
 *
 * Useful when combined with vibrancy views or custom rendering
 *
 * @param window - Electron BrowserWindow instance
 */
export function setWindowTransparent(window: BrowserWindow): boolean {
  try {
    const handle = getWindowHandle(window);
    return native.setWindowTransparent(handle);
  } catch (error) {
    console.error('Failed to set window transparent:', error);
    return false;
  }
}

// Re-export types for convenience
export * from './types';

# AI Agent Instructions (AGENTS.md)

This document contains rules, context, and operational guidelines for Autonomous AI Agents (such as LLM coding assistants) when working on the **Hangul Clock Panel Maker** codebase. 

> **Notice to AI Agents:** Both this `AGENTS.md` and the `README.md` are subject to automatic updates by AI assistants as the project evolves, ensuring long-term consistency and clarity.

## Project Context
- **Purpose**: A web-based configuration tool for generating high-resolution (300 DPI) Hangul Clock panel images.
- **Language**: The UI components are predominantly in Korean to serve local users. Source code variables, comments, and logic strictly use English semantics.
- **Key Output**: The app generates an image file (`.png`) formatted from a HTML5 `<canvas>` element, mirroring real-world millimeter dimensions for scenarios like UV printing, vinyl sheet cutting, or translucent acrylic printing.

## Technologies & Specifications
- **Framework**: Svelte 5
  - **Rules**: You MUST use modern Svelte 5 native "Runes" (`$state`, `$derived`, `$effect`, `$props`, `$bindable`, etc.). Do NOT introduce legacy Svelte 4 properties (e.g., `export let prop`, `$: reactive`).
  - **Target Directory**: The Svelte application lives inside the `/svelte-app` directory. Component and logic codes are under `/svelte-app/src`.
- **Builder**: Vite
- **Styling**: Vanilla CSS located within `.svelte` file `<style>` tags or generic `global.css`. Do not add heavy utility CSS libraries (like TailwindCSS) unless explicitly prompted by the USER.

## Architecture & Logic Handling
- **Canvas Rendering**: 
  - All canvas manipulations and drawing interactions happen reactively inside an `$effect` block. 
  - Ensure the dependencies (dimensions, colors, selected fonts, `fontReadyVersion`) are correctly referenced at the top of the `$effect` scope for re-rendering on value change.
  - Make sure that external assets (like TTF Fontface or Web Fonts) are completely loaded into `document.fonts` before invoking `fillText`. Failing to do so causes a blank render.
- **Math/Conversions**: The function `mmToPx(mm, dpi)` translates exact millimeter sizes to pixel outputs. Ensure `Math.round` is preserved so that exact integer sizing limits are passed to the canvas attributes.

## Agent Behavior rules
1. **Never mock functionality**: Do not insert placeholder components or dummy images if a real programmatic method is viable.
2. **Minimal dependency footprint**: Do not install external formatting or state management npm modules. Svelte 5 runes handle reactivity perfectly well.
3. **Keep Korean text native**: Modify functional labels to fit the Korean UI, making sure spelling is coherent. (e.g. Instead of "Download", use "다운로드"; instead of "Color Invert", use "색상 반전").

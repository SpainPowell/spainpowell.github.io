import { readFile } from "node:fs/promises";
import { access } from "node:fs/promises";

const requiredFiles = [
  "index.html",
  "whiff.html",
  "styles.css",
  "whiff.css",
  "site.js",
  "og-image.svg",
  "og-image.png",
  "handoff/assets/favicon.svg",
  "projects/whiff/whiff-lockup-reverse.svg",
  "projects/whiff/share-sheet-web.png",
  "projects/whiff/receipt-link-card.png",
  "projects/whiff/fonts/OFL.txt",
];
const files = Object.fromEntries(await Promise.all(requiredFiles.map(async (file) => [file, await readFile(file, "utf8")])));
const html = files["index.html"];
const css = files["styles.css"];
const js = files["site.js"];
const whiffHtml = files["whiff.html"];
const whiffCss = files["whiff.css"];
const failures = [];

for (const file of requiredFiles) {
  try {
    await access(file);
  } catch {
    failures.push(`Missing required file: ${file}`);
  }
}

const checks = [
  [html.startsWith("<!doctype html>"), "index.html has a doctype"],
  [html.includes('<html lang="en"'), "index.html declares a document language"],
  [html.includes('id="main-content"'), "index.html has a main landmark"],
  [html.includes('id="main-content" tabindex="-1"'), "skip-link target can receive focus"],
  [html.includes('id="work"') && html.includes('id="about"') && html.includes('id="contact"'), "primary sections are present"],
  [html.includes('rel="icon"'), "favicon metadata is present"],
  [html.includes('og-image.png') && html.includes('og:image:width" content="1200"') && html.includes('og:image:height" content="630"') && html.includes('summary_large_image'), "social image metadata is present"],
  [html.includes('rel="canonical" href="https://spainpowell.github.io/"'), "homepage canonical URL is present"],
  [!html.match(/(?:src|href)="\//) && !css.includes('url("/'), "site asset paths are portable"],
  [css.includes("prefers-reduced-motion"), "reduced-motion support is present"],
  [css.includes("--clay: #de8248") && css.includes("--pacific: #2f8578"), "handoff palette tokens are present"],
  [js.includes("localStorage") && js.includes("data-theme"), "theme preference logic is present"],
  [html.includes('href="https://www.linkedin.com/in/spain-powell/"'), "contact link is explicit"],
  [html.includes('href="https://win-the-numbers.vercel.app/"') && html.includes('noopener noreferrer'), "Win The Numbers product link is present and isolated"],
  [html.includes('href="whiff.html"'), "Whiff case study is linked from selected work"],
  [html.includes('href="https://www.whiffsports.com"') && html.includes('aria-label="Visit the live Whiff website (opens in a new tab)"'), "Whiff live product is linked from selected work"],
  [whiffHtml.includes('id="decisions"') && whiffHtml.includes('id="evidence"'), "Whiff narrative sections are present"],
  [!whiffHtml.match(/\{\{[A-Z_]+\}\}/), "Whiff pre-publish placeholders are resolved"],
  [whiffHtml.includes('href="https://www.whiffsports.com"') && whiffHtml.includes('rel="noopener noreferrer"'), "Whiff live product link is explicit and isolated"],
  [whiffHtml.includes('<dt>Site visits</dt><dd>5,680</dd>') && whiffHtml.includes('<dt>Users</dt><dd>68</dd>') && whiffHtml.includes('<dt>Active pools</dt><dd>3</dd>'), "Whiff measured outcomes are present"],
  [whiffHtml.includes('Synthetic fixture') && whiffHtml.includes('Design reference'), "Whiff proof assets are labeled"],
  [whiffHtml.includes('og:image') && whiffHtml.includes('receipt-link-card.png') && whiffHtml.includes('summary_large_image'), "Whiff social preview metadata is present"],
  [whiffHtml.includes('width="1280" height="400" fetchpriority="high"') && whiffHtml.includes('width="1200" height="630" loading="lazy"'), "Whiff imagery reserves layout space and prioritizes the hero lockup"],
  [whiffCss.includes('@font-face') && whiffCss.includes('prefers-reduced-motion'), "Whiff brand fonts and reduced-motion support are scoped"],
  [html.includes('role="group" aria-labelledby="current-focus-heading"'), "current-focus panel has a group label"],
];

for (const [passed, description] of checks) {
  if (!passed) failures.push(`Check failed: ${description}`);
}

if (failures.length) {
  console.error(failures.join("\n"));
  process.exitCode = 1;
} else {
  console.log(`Verified ${requiredFiles.length} required files and ${checks.length} site checks.`);
}

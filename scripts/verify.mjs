import { readFile } from "node:fs/promises";
import { access } from "node:fs/promises";

const requiredFiles = ["index.html", "styles.css", "site.js", "og-image.svg", "handoff/assets/favicon.svg"];
const files = Object.fromEntries(await Promise.all(requiredFiles.map(async (file) => [file, await readFile(file, "utf8")])));
const html = files["index.html"];
const css = files["styles.css"];
const js = files["site.js"];
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
  [html.includes('id="work"') && html.includes('id="about"') && html.includes('id="contact"'), "primary sections are present"],
  [html.includes('rel="icon"'), "favicon metadata is present"],
  [html.includes('og-image.svg') && html.includes('og:image:width" content="1200"') && html.includes('og:image:height" content="630"'), "social image metadata is present"],
  [!html.match(/(?:src|href)="\//) && !css.includes('url("/'), "site asset paths are portable"],
  [css.includes("prefers-reduced-motion"), "reduced-motion support is present"],
  [css.includes("--clay: #de8248") && css.includes("--pacific: #2f8578"), "handoff palette tokens are present"],
  [js.includes("localStorage") && js.includes("data-theme"), "theme preference logic is present"],
  [html.includes('href="https://www.linkedin.com/in/spain-powell/"'), "contact link is explicit"],
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

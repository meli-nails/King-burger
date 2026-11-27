import { readFileSync } from "node:fs";
import { Script } from "node:vm";

const pages = ["index.html", "admin.html", "seguimiento.html"];
let errors = 0;

for (const page of pages) {
  const html = readFileSync(new URL("../" + page, import.meta.url), "utf8");
  const blocks = [...html.matchAll(/<script(?:\\s[^>]*)?>([\\s\\S]*?)<\\/script>/gi)];
  if (!blocks.length) {
    console.error("No inline scripts found:", page);
    errors++;
    continue;
  }

  blocks.forEach((match, index) => {
    try {
      new Script(match[1], { filename: page + "#script-" + (index + 1) });
      console.log("OK", page, "script", index + 1);
    } catch (error) {
      console.error("FAIL", page, "script", index + 1, error.message);
      errors++;
    }
  });
}

if (errors) process.exitCode = 1;
else console.log("All inline JavaScript blocks passed syntax validation.");

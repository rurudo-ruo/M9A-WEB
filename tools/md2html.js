import markdownit from "markdown-it";
import hljs from "highlight.js";
import MarkdownItGitHubAlerts from "markdown-it-github-alerts";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const md = markdownit({
  html: true,
  linkify: true,
  typographer: true,
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(str, { language: lang }).value;
      } catch (__) {}
    }

    return ""; // use external default escaping
  },
});
md.use(MarkdownItGitHubAlerts);
md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
  const token = tokens[idx];
  const hrefIndex = token.attrIndex("href");
  const href = token.attrs[hrefIndex][1];

  if (/^https?:\/\//.test(href)) {
    token.attrPush(["target", "_top"]);
    token.attrPush(["rel", "noopener noreferrer"]);
  }

  return self.renderToken(tokens, idx, options);
};

function convertMd(file) {
  let mdContent = fs.readFileSync(file, "utf-8");
  const start = mdContent.indexOf("## Star History");
  if (start != -1) {
    const end = mdContent.indexOf("</a>", start);
    mdContent = mdContent.substring(0, start) + mdContent.substring(end);
  }
  const html = md
    .render(mdContent)
    .replaceAll(".md", ".html")
    .replace(
      "https://github.com/user-attachments/assets/b8e4d737-d549-43f3-a2e7-a3727bf615a9",
      "/assets/image/logo.webp"
    ); // LOGO切换为该网站的链接;
  const filePath = file.replace("md/", "dist/").replace(".md", ".html");
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(
    filePath,
    `<!DOCTYPE html>
<html>

<head>
    <link rel="stylesheet" href="/assets/css/markdown.css">
    <link rel="stylesheet" href="/assets/css/github-markdown-light.css">
</head>

<body>
    <article class="markdown-body">
${html}
    </article>
</body>

</html>`
  );
}

function convertDir(dir) {
  fs.readdirSync(dir, {
    withFileTypes: true,
  }).forEach((dirent) => {
    if (dirent.isDirectory()) {
      convertDir(path.join(dir, dirent.name));
    } else if (dirent.isFile() && dirent.name.endsWith(".md")) {
      convertMd(path.join(dir, dirent.name).replaceAll("\\", "/"));
    }
  });
}

function main() {
  convertDir(path.join(__dirname, "..", "md"));
  fs.cpSync(
    path.join(__dirname, "..", "assets"),
    path.join(__dirname, "..", "dist", "assets"),
    { recursive: true }
  );
  fs.cpSync(
    path.join(__dirname, "..", "index.html"),
    path.join(__dirname, "..", "dist", "index.html")
  );
  fs.cpSync(
    path.join(__dirname, "..", "CNAME"),
    path.join(__dirname, "..", "dist", "CNAME")
  );
}

main();

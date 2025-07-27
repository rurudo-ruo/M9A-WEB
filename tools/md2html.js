import markdownit from "markdown-it";
import hljs from "highlight.js";
import MarkdownItGitHubAlerts from "markdown-it-github-alerts";
import MarkdownItAnchor from "markdown-it-anchor";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { argv } from "process";

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

    return "";
  },
});
md.use(MarkdownItGitHubAlerts);
md.use(MarkdownItAnchor, {
  getTokensText: (tokens) => {
    return tokens[0].content.replaceAll(".", "")
  },
});
md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
  const token = tokens[idx];
  const hrefIndex = token.attrIndex("href");
  const href = token.attrs[hrefIndex][1];

  if (/^https?:\/\//.test(href)) {
    token.attrPush(["target", "_top"]);
    token.attrPush(["rel", "noopener noreferrer"]);
  } else if (
    href.includes(".md") &&
    (href.startsWith(".") || href.startsWith("/"))
  ) {
    tokens[idx].attrs[hrefIndex][1] = href.replace(".md", ".html?iframe");
  }

  return self.renderToken(tokens, idx, options);
};

function convertMd(file, baseDir) {
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
  const filePath = file.replace(`${baseDir}/`, "dist/").replace(".md", ".html");
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  console.log(filePath, baseDir);
  fs.writeFileSync(
    filePath,
    `<!DOCTYPE html>
<html>

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script src="/assets/js/iframe.js"></script>
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

function convertDir(dir, baseDir) {
  fs.readdirSync(dir, {
    withFileTypes: true,
  }).forEach((dirent) => {
    if (dirent.isDirectory()) {
      convertDir(path.join(dir, dirent.name), baseDir);
    } else if (dirent.isFile() && dirent.name.endsWith(".md")) {
      convertMd(path.join(dir, dirent.name).replaceAll("\\", "/"), baseDir);
    }
  });
}

function main() {
  const filePath = argv[2] ?? path.join(__dirname, "..", "md");
  convertDir(filePath, path.basename(filePath));
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

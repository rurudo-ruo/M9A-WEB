# M9A-WEB

M9A 文档站。本项目负责存放图片和构建部署文档站，若想修改文档内容请到 [M9A](https://github.com/MAA1999/M9A/docs)  
文档站使用 [Plume 主题](https://theme-plume.vuejs.press/guide/intro/)

开发与本地运行：

首次开发或每次需要同步最新文档时，先运行同步脚本：

win pwsh：

```powershell
./tools/sync-docs.ps1
```

bash：

```bash
./tools/sync-docs.sh
```

然后再安装依赖并启动本地服务：

```powershell
pnpm install
pnpm run docs:dev
```

构建生产包：

```powershell
pnpm run docs:build
pnpm run docs:preview
```

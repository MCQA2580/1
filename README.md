# 图片查看器部署指南

## 项目结构

```
├── public/              # Cloudflare Pages 部署目录
│   ├── index.html       # 主页面
│   ├── downloaded_images/  # 图片存储目录
│   ├── _redirects       # Cloudflare Pages 重定向规则
│   └── _headers         # Cloudflare Pages HTTP 头配置
├── downloaded_images/   # 原始图片目录
├── deploy/              # 部署相关文件
├── .github/workflows/   # GitHub Actions 工作流
└── simple_image_viewer.html  # 主页面源文件
```

## Cloudflare Pages 部署步骤

1. **登录 Cloudflare 账户**
   - 访问 https://dash.cloudflare.com
   - 登录您的 Cloudflare 账户

2. **创建 Pages 项目**
   - 点击左侧菜单中的 "Pages"
   - 点击 "Create a project"
   - 选择 "Connect to Git"
   - 选择您的 GitHub 仓库

3. **配置部署设置**
   - **Production branch**: 选择您的主分支（如 main）
   - **Build command**: 留空（不需要构建步骤）
   - **Build output directory**: `public`
   - 点击 "Save and Deploy"

4. **等待部署完成**
   - Cloudflare Pages 将自动部署您的网站
   - 部署完成后，您将获得一个 `.pages.dev` 域名

## 访问网站

部署完成后，您可以通过以下方式访问您的网站：

- **Cloudflare Pages 域名**: `https://<project-name>.pages.dev`
- **自定义域名** (可选): 您可以在 Cloudflare Pages 设置中添加自定义域名

## 自动更新

当您向 `downloaded_images` 目录添加新图片时：

1. 提交并推送更改到 GitHub
2. GitHub Actions 将自动运行 `update-viewer.yml` 工作流
3. 工作流将更新 `simple_image_viewer.html` 和 `public` 目录
4. Cloudflare Pages 将自动重新部署您的网站

## 图片管理

- **添加图片**: 将新图片添加到 `downloaded_images` 目录并提交
- **删除图片**: 从 `downloaded_images` 目录删除图片并提交
- **查看图片**: 访问 `https://<project-name>.pages.dev/downloaded_images` 查看所有图片

## 故障排除

### 404 错误
- 确保 `public` 目录存在
- 确保 `public/index.html` 文件存在
- 确保 `public/downloaded_images` 目录存在

### 图片加载失败
- 确保图片文件格式正确（JPG）
- 确保图片文件权限正确
- 检查网络连接

### 部署失败
- 检查 GitHub Actions 工作流运行状态
- 检查 Cloudflare Pages 部署日志
- 确保仓库中有 `public` 目录
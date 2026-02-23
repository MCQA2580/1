# 图片查看器项目

## 项目简介

这是一个简单的图片查看器项目，用于展示从API下载的图片。项目特点：

- 📁 图片以数字格式命名（1.jpg, 2.jpg, ..., N.jpg）
- 🌐 使用 Cloudflare Workers 部署
- 🔄 支持自动更新（通过 GitHub Actions）
- 🎯 随机显示图片功能
- 📱 响应式设计，支持移动端

## 项目结构

```
├── downloaded_images/   # 图片存储目录（数字命名格式）
├── deploy/              # Cloudflare Workers 部署文件
│   ├── worker.js        # Workers 脚本
│   ├── package.json     # 依赖配置
│   ├── wrangler.toml    # Wrangler 配置
│   └── update_image_viewer.ps1  # 图片更新脚本
├── .github/workflows/   # GitHub Actions 工作流
│   └── update-viewer.yml  # 自动更新工作流
├── simple_image_viewer.html  # 本地图片查看器
└── README.md            # 项目说明文档
```

## 部署方式

### 1. Cloudflare Workers 部署

1. **准备工作**
   - 安装 Wrangler CLI：`npm install -g wrangler`
   - 登录 Cloudflare 账户：`wrangler login`

2. **配置 Wrangler**
   - 编辑 `deploy/wrangler.toml` 文件，设置您的 Cloudflare 账户 ID 和项目名称

3. **部署 Workers**
   - 进入 deploy 目录：`cd deploy`
   - 执行部署命令：`wrangler deploy`

4. **获取部署 URL**
   - 部署完成后，Wrangler 会显示您的 Workers 部署 URL
   - 示例：`https://your-project.your-username.workers.dev`

### 2. 本地开发

直接在浏览器中打开 `simple_image_viewer.html` 文件即可查看本地图片。

## 图片管理

### 添加新图片

1. **下载图片**
   - 将新图片下载到 `downloaded_images` 目录
   - 确保图片格式为 JPG

2. **重命名图片**
   - 新图片应按照数字顺序命名，例如：
     - 如果当前最后一张图片是 `237.jpg`
     - 新图片应命名为 `238.jpg`, `239.jpg`, 以此类推

3. **更新配置**
   - 编辑 `deploy/worker.js` 文件
   - 更新 `totalImages` 变量的值为新的图片总数
   - 例如：`const totalImages = 240;`（如果添加了3张新图片）

4. **提交更改**
   - 提交并推送所有更改到 GitHub
   - GitHub Actions 会自动运行更新工作流

### 删除图片

1. **删除图片文件**
   - 从 `downloaded_images` 目录中删除不需要的图片

2. **重新编号图片**
   - 为了保持数字序列的连续性，建议重新编号剩余图片
   - 例如：如果删除了 `5.jpg`，将 `6.jpg` 重命名为 `5.jpg`，以此类推

3. **更新配置**
   - 编辑 `deploy/worker.js` 文件
   - 更新 `totalImages` 变量的值为新的图片总数

4. **提交更改**
   - 提交并推送所有更改到 GitHub

## 自动更新配置

项目使用 GitHub Actions 实现自动更新：

1. **工作流文件**：`.github/workflows/update-viewer.yml`
2. **触发条件**：当向 `main` 分支推送更改时
3. **执行任务**：
   - 检查图片目录
   - 更新图片查看器配置
   - 准备部署文件

## 访问方式

### 1. Cloudflare Workers

- **主要访问方式**：通过 Workers 部署 URL 访问
- **功能**：随机显示图片，支持查看所有图片

### 2. GitHub 原始存储

- **查看所有图片**：`https://github.com/MCQA2580/1/tree/main/downloaded_images`
- **直接访问单张图片**：`https://raw.githubusercontent.com/MCQA2580/1/main/downloaded_images/1.jpg`

## 故障排除

### 常见问题

1. **图片加载失败**
   - 检查图片文件是否存在且命名正确
   - 检查网络连接
   - 确认 `totalImages` 变量设置正确

2. **Workers 部署失败**
   - 检查 `wrangler.toml` 配置是否正确
   - 确认 Cloudflare 账户已登录
   - 查看部署日志了解详细错误

3. **自动更新不工作**
   - 检查 GitHub Actions 工作流是否启用
   - 查看工作流运行日志
   - 确认仓库权限设置正确

### 错误代码

- **404 Not Found**：图片文件不存在或路径错误
- **500 Internal Server Error**：Workers 脚本错误
- **403 Forbidden**：权限不足

## 技术栈

- **前端**：HTML, CSS, JavaScript
- **部署**：Cloudflare Workers
- **自动化**：GitHub Actions
- **脚本**：PowerShell

## 许可

MIT License

## 更新日志

### 2026-02-23
- ✅ 图片重命名为数字格式（1.jpg, 2.jpg, ...）
- ✅ 更新 Cloudflare Workers 部署配置
- ✅ 优化图片加载逻辑
- ✅ 支持自动更新新添加的图片
- ✅ 简化项目结构

---

**注意**：项目正在持续更新中，如有任何问题，请提交 Issue 或联系项目维护者。
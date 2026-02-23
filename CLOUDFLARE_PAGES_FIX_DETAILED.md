# Cloudflare Pages 部署错误详细修复指南

## 错误分析

从部署日志可以看到：

```
2026-02-23T14:53:33.153Z	Executing user deploy command: npx wrangler deploy
```

**根本原因**：Cloudflare Pages 项目配置中，"Build command" 字段错误地设置为 `npx wrangler deploy`。

`npx wrangler deploy` 是用于部署 Cloudflare Workers 的命令，不是用于部署静态站点的。

## 修复步骤（带截图说明）

### 步骤 1：登录 Cloudflare 账户

1. 访问 https://dash.cloudflare.com
2. 输入您的邮箱和密码登录

### 步骤 2：找到您的 Pages 项目

1. 在左侧菜单中点击 "Pages"
2. 找到您的图片查看器项目（应该是 `1-91c`）
3. 点击项目名称进入详情页

### 步骤 3：修改构建配置

1. 点击顶部的 "Settings" 选项卡
2. 在左侧菜单中点击 "Builds & deployments"
3. 找到 "Build settings" 部分

### 步骤 4：更新构建命令

1. **清除 Build command 字段**：
   - 点击 "Build command" 输入框
   - 删除里面的 `npx wrangler deploy`
   - 确保输入框为空

2. **验证 Build output directory**：
   - 确保 "Build output directory" 字段设置为 `public`
   - 如果不是，请修改为 `public`

3. **保存更改**：
   - 点击 "Save changes" 按钮

### 步骤 5：重新部署

1. 点击顶部的 "Deployments" 选项卡
2. 点击 "Trigger deployment" 按钮
3. 在弹出的对话框中：
   - 选择您的主分支（如 main）
   - 点击 "Deploy" 按钮

## 正确的配置设置

| 配置项 | 正确值 | 错误值 |
|-------|-------|-------|
| Production branch | main（或您的主分支） | 任何分支都可以 |
| Build command | **留空** | `npx wrangler deploy` |
| Build output directory | `public` | 任何其他值 |

## 为什么这样配置

- **留空 Build command**：我们的网站是静态的，不需要任何构建步骤。所有文件都已经在 `public` 目录中准备好了。

- **设置 Build output directory 为 `public`**：这告诉 Cloudflare Pages 从 `public` 目录中获取要部署的文件。

## 项目结构验证

确保您的项目结构如下：

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

## 验证部署

部署完成后，您可以通过以下方式验证：

1. **访问网站**：打开您的 `.pages.dev` 域名（如 `1-91c.pages.dev`）

2. **测试功能**：
   - 点击 "查看示例图片" 按钮，应该能看到随机图片
   - 点击 "打开图片文件夹" 按钮，应该能看到所有图片
   - 检查页面是否正常加载，没有错误

3. **检查部署日志**：
   - 在 "Deployments" 选项卡中，查看最新部署的日志
   - 应该看到 "Success: Deployment completed" 或类似的成功消息

## 常见问题排查

### 问题 1：构建命令仍然是 `npx wrangler deploy`
- **解决方案**：确保您在 Cloudflare Pages 仪表板中正确修改了构建命令，并点击了 "Save changes" 按钮

### 问题 2：部署成功但页面显示 404
- **解决方案**：
  - 确保 `public/index.html` 文件存在
  - 确保 `public` 目录被包含在版本控制中
  - 检查 `_redirects` 文件是否正确配置

### 问题 3：图片加载失败
- **解决方案**：
  - 确保 `public/downloaded_images` 目录存在
  - 确保图片文件已正确复制到该目录
  - 检查图片路径是否正确

### 问题 4：GitHub Actions 不更新 `public` 目录
- **解决方案**：
  - 检查 `.github/workflows/update-viewer.yml` 文件是否正确配置
  - 确保工作流有权限写入仓库
  - 检查工作流日志是否有错误

## 联系支持

如果您仍然遇到问题：

1. **检查 Cloudflare Pages 文档**：https://developers.cloudflare.com/pages/

2. **联系 Cloudflare 支持**：
   - 在 Cloudflare 仪表板中点击右下角的 "Help" 按钮
   - 选择 "Contact Support"
   - 提供您的部署日志和项目信息

3. **检查 GitHub 仓库**：
   - 确保所有文件都已提交并推送到 GitHub
   - 确保 `public` 目录包含所有必要的文件

## 总结

修复 Cloudflare Pages 部署错误的关键是：

1. **清除 Build command 字段**：删除 `npx wrangler deploy`
2. **设置 Build output directory 为 `public`**
3. **重新部署** 您的网站

这样配置后，Cloudflare Pages 将正确部署您的静态图片查看器网站，而不是尝试使用 Wrangler 部署 Workers。
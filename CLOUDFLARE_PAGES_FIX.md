# Cloudflare Pages 部署错误修复指南

## 错误原因

从部署日志中可以看到：

```
2026-02-23T14:49:41.185Z	Executing user deploy command: npx wrangler deploy
```

**问题**：在 Cloudflare Pages 项目配置中错误地设置了 `npx wrangler deploy` 作为部署命令。

- `npx wrangler deploy` 是用于部署 Cloudflare Workers 的命令
- 对于静态站点（如我们的图片查看器），不需要使用此命令
- 这导致部署失败，因为 Wrangler 找不到有效的 Worker 配置

## 修复步骤

1. **登录 Cloudflare 账户**
   - 访问 https://dash.cloudflare.com
   - 登录您的 Cloudflare 账户

2. **找到您的 Pages 项目**
   - 点击左侧菜单中的 "Pages"
   - 找到您的图片查看器项目并点击进入

3. **修改构建配置**
   - 点击 "Settings" 选项卡
   - 点击 "Builds & deployments"
   - 找到 "Build settings" 部分

4. **更新构建命令**
   - 将 "Build command" 字段留空（删除 `npx wrangler deploy`）
   - 确保 "Build output directory" 字段设置为 `public`
   - 点击 "Save changes"

5. **重新部署**
   - 点击 "Deployments" 选项卡
   - 点击 "Trigger deployment" 按钮
   - 选择您的主分支（如 main）并点击 "Deploy"

## 正确的配置设置

| 配置项 | 值 |
|-------|-----|
| Production branch | main（或您的主分支） |
| Build command | 留空（不需要构建步骤） |
| Build output directory | `public` |

## 为什么这样配置

- **留空构建命令**：我们的网站是静态的，不需要任何构建步骤
- **设置构建输出目录为 `public`**：这告诉 Cloudflare Pages 从 `public` 目录中获取要部署的文件

## 验证部署

部署完成后，您可以：

1. 访问您的 `.pages.dev` 域名
2. 检查网站是否正常加载
3. 点击 "查看示例图片" 按钮测试图片加载
4. 点击 "打开图片文件夹" 按钮查看所有图片

## 常见问题排查

### 404 错误
- 确保 `public` 目录存在
- 确保 `public/index.html` 文件存在
- 确保 `public/downloaded_images` 目录存在

### 图片加载失败
- 确保图片文件已正确复制到 `public/downloaded_images` 目录
- 确保图片文件格式正确（JPG）
- 检查网络连接

### 部署失败
- 确保构建命令留空
- 确保构建输出目录设置为 `public`
- 检查 GitHub 仓库是否包含 `public` 目录
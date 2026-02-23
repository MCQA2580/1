# 自动更新图片查看器脚本
# 扫描downloaded_images文件夹，更新simple_image_viewer.html中的示例图片列表

Write-Host "开始更新图片查看器..." -ForegroundColor Cyan

$imageFolder = ".\downloaded_images"
$htmlFile = ".\simple_image_viewer.html"

# 检查文件夹和文件是否存在
if (-not (Test-Path -Path $imageFolder)) {
    Write-Host "错误: 图片文件夹不存在!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -Path $htmlFile)) {
    Write-Host "错误: simple_image_viewer.html文件不存在!" -ForegroundColor Red
    exit 1
}

# 获取所有jpg文件
$imageFiles = Get-ChildItem -Path $imageFolder -Filter "*.jpg" -File
$totalCount = $imageFiles.Count

if ($totalCount -eq 0) {
    Write-Host "错误: 没有找到jpg文件!" -ForegroundColor Red
    exit 1
}

Write-Host "找到 $totalCount 张图片" -ForegroundColor Yellow

# 随机选择10张图片作为示例
$sampleCount = [Math]::Min(10, $totalCount)
$sampleImages = $imageFiles | Get-Random -Count $sampleCount

Write-Host "随机选择了 $sampleCount 张图片作为示例" -ForegroundColor Green

# 生成JavaScript数组字符串
$jsArray = "[
"
foreach ($image in $sampleImages) {
    $jsArray += "    '${image.Name}',
"
}
$jsArray += "]"

# 读取HTML文件内容
$htmlContent = Get-Content -Path $htmlFile -Raw

# 更新示例图片数组
$oldPattern = "const sampleImages = \[.*?\];"
$newPattern = "const sampleImages = $jsArray;"

$updatedContent = $htmlContent -replace $oldPattern, $newPattern

# 保存更新后的HTML文件
Set-Content -Path $htmlFile -Value $updatedContent -Encoding UTF8

Write-Host "" 
Write-Host "图片查看器更新完成!" -ForegroundColor Green
Write-Host "更新文件: $htmlFile" -ForegroundColor Cyan
Write-Host "总图片数: $totalCount" -ForegroundColor Cyan
Write-Host "示例图片数: $sampleCount" -ForegroundColor Cyan
Write-Host "" 
Write-Host "使用方法: 在添加新图片后运行此脚本，然后刷新浏览器中的图片查看器页面" -ForegroundColor Yellow
Write-Host "" 
Write-Host "现在可以在浏览器中打开 simple_image_viewer.html 查看更新后的图片" -ForegroundColor Cyan
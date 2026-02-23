# 从338开始下载图片到1000张
# 使用API: https://www.dmoe.cc/random.php

Write-Host "开始从API下载图片 (338-1000)..."
Write-Host ""

$imageFolder = ".\downloaded_images"
$startIndex = 338
$endIndex = 1000
$totalToDownload = $endIndex - $startIndex + 1

# 检查文件夹是否存在
if (-not (Test-Path -Path $imageFolder)) {
    Write-Host "错误: 图片文件夹不存在!"
    exit 1
}

Write-Host "下载范围: $startIndex 到 $endIndex"
Write-Host "需要下载: $totalToDownload 张图片"
Write-Host ""

$successCount = 0
$failedCount = 0

for ($i = $startIndex; $i -le $endIndex; $i++) {
    try {
        $newName = "$i.jpg"
        $outputPath = Join-Path -Path $imageFolder -ChildPath $newName
        
        Write-Host "下载第 $i 张图片..."
        
        # 直接从API下载图片（API返回原始JPEG数据）
        Invoke-WebRequest -Uri "https://www.dmoe.cc/random.php" -OutFile $outputPath -ErrorAction Stop
        
        # 验证文件大小（确保下载成功）
        $fileSize = (Get-Item $outputPath).Length
        if ($fileSize -lt 1024) {
            Write-Host "警告: 文件大小异常，可能下载失败!"
            Remove-Item $outputPath -Force
            $failedCount++
            continue
        }
        
        Write-Host "成功: 下载并保存为 $newName"
        $successCount++
        
        # 随机延迟，避免请求过于频繁
        Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 2000)
        
    } catch {
        Write-Host "失败: 无法下载第 $i 张图片"
        Write-Host "错误信息: $($_.Exception.Message)"
        $failedCount++
        
        # 失败后延迟更长时间
        Start-Sleep -Seconds 2
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "===================================="
Write-Host "下载完成!"
Write-Host "总任务: $totalToDownload 张"
Write-Host "成功下载: $successCount 张"
Write-Host "下载失败: $failedCount 张"
Write-Host "===================================="
Write-Host ""

# 更新 worker.js 文件中的图片总数
Write-Host "更新 worker.js 文件中的图片总数..."
try {
    $workerJsPath = ".\deploy\worker.js"
    if (Test-Path -Path $workerJsPath) {
        $content = Get-Content -Path $workerJsPath -Raw
        
        # 替换 totalImages 变量的值
        $updatedContent = $content -replace 'const totalImages = \d+;', "const totalImages = $endIndex;"
        
        # 替换图片数量显示
        $updatedContent = $updatedContent -replace '• 图片数量: \d+ 张', "• 图片数量: $endIndex 张"
        
        # 保存更新后的内容
        Set-Content -Path $workerJsPath -Value $updatedContent -Force
        
        Write-Host "成功: 更新了 worker.js 文件，图片总数设置为 $endIndex"
    } else {
        Write-Host "错误: worker.js 文件不存在!"
    }
} catch {
    Write-Host "错误: 更新 worker.js 文件失败"
    Write-Host "错误信息: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "所有操作完成!"

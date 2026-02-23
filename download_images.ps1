# 下载图片脚本
# 从338开始下载到1000

$start = 338
$end = 1000
$folder = ".\downloaded_images"

Write-Host "开始下载图片 $start 到 $end"

if (-not (Test-Path $folder)) {
    Write-Host "文件夹不存在，创建中..."
    New-Item -ItemType Directory -Path $folder
}

for ($i = $start; $i -le $end; $i++) {
    $file = "$i.jpg"
    $path = Join-Path $folder $file
    
    Write-Host "下载 $file..."
    
    try {
        Invoke-WebRequest -Uri "https://www.dmoe.cc/random.php" -OutFile $path -TimeoutSec 30
        Write-Host "成功: $file"
        
        # 延迟
        Start-Sleep -Milliseconds 1000
    } catch {
        Write-Host "失败: $file"
        Write-Host "错误: $($_.Exception.Message)"
    }
}

Write-Host "下载完成!"

# 更新worker.js
$workerPath = ".\deploy\worker.js"
if (Test-Path $workerPath) {
    Write-Host "更新 worker.js 中的图片总数..."
    $content = Get-Content $workerPath -Raw
    $newContent = $content -replace 'const totalImages = \d+;', "const totalImages = $end;"
    $newContent = $newContent -replace '• 图片数量: \d+ 张', "• 图片数量: $end 张"
    Set-Content $workerPath -Value $newContent
    Write-Host "更新完成!"
}

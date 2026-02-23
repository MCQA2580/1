# 简单下载脚本
$folder = "./downloaded_images"

for ($i=338; $i -le 1000; $i++) {
    $file = "$i.jpg"
    $path = "$folder/$file"
    
    Write-Host "Downloading $file..."
    
    try {
        Invoke-WebRequest -Uri "https://www.dmoe.cc/random.php" -OutFile $path -TimeoutSec 30
        Write-Host "OK: $file"
    } catch {
        Write-Host "FAILED: $file"
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "Done!"

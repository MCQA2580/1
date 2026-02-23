@echo off
setlocal enabledelayedexpansion

echo 开始下载图片 338-1000
echo.

set "folder=downloaded_images"
set "start=338"
set "end=1000"

if not exist "%folder%" (
    echo 创建文件夹 %folder%
    mkdir "%folder%"
)

for /l %%i in (%start%,1,%end%) do (
    echo 下载 %%i.jpg...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.dmoe.cc/random.php' -OutFile '%folder%\%%i.jpg' -TimeoutSec 30"
    if %errorlevel% equ 0 (
        echo 成功: %%i.jpg
    ) else (
        echo 失败: %%i.jpg
    )
    echo.
    :: 延迟1秒
    timeout /t 1 /nobreak >nul
)

echo 下载完成!
echo.
pause

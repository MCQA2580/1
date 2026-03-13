# DMOE Image Download Script (Multi-threaded)
# Download images from https://www.dmoe.cc/random.php and preserve original naming

Write-Host "Starting DMOE image download process (Multi-threaded)..." -ForegroundColor Cyan

$baseUrl = "https://www.dmoe.cc/random.php"
$outputDir = ".\downloaded_images"
$targetCount = 3000
$batchSize = 100 # Download in batches to avoid sandbox limitations
$delay = 1 # seconds between batches

# Create output directory if it doesn't exist
if (-not (Test-Path -Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
    Write-Host "Created output directory: $outputDir" -ForegroundColor Green
}

# Function to download a batch of images
function Download-Batch {
    param(
        [int]$StartIndex,
        [int]$BatchSize
    )
    
    $batchSuccess = 0
    $batchError = 0
    
    for ($i = 0; $i -lt $BatchSize; $i++) {
        $currentIndex = $StartIndex + $i
        
        if ($currentIndex -gt $targetCount) {
            break
        }
        
        try {
            # Get image content
            $response = Invoke-WebRequest -Uri $baseUrl -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -UseBasicParsing
            
            # Generate filename
            $filename = "image_$(Get-Date -Format 'yyyyMMdd_HHmmss_')$(Get-Random).jpg"
            $outputFile = Join-Path -Path $outputDir -ChildPath $filename
            
            # Save image
            Set-Content -Path $outputFile -Value $response.Content -Encoding Byte
            
            $message = "Downloaded image " + $currentIndex + ": " + $filename
            Write-Host $message -ForegroundColor Green
            $batchSuccess++
            
            # Add small delay between requests
            Start-Sleep -Milliseconds 500
            
        } catch {
            $errorMessage = $_.Exception.Message
            $message = "Failed to download image " + $currentIndex + ": " + $errorMessage
            Write-Host $message -ForegroundColor Red
            $batchError++
            
            # Add extra delay after failure
            Start-Sleep -Seconds 2
        }
    }
    
    return @($batchSuccess, $batchError)
}

# Download images in batches
$successCount = 0
$errorCount = 0

Write-Host "Starting download in batches..." -ForegroundColor Cyan

for ($i = 1; $i -le $targetCount; $i += $batchSize) {
    $endIndex = [Math]::Min($i + $batchSize - 1, $targetCount)
    Write-Host "Downloading batch $i-$endIndex/$targetCount..." -ForegroundColor Cyan
    
    $result = Download-Batch -StartIndex $i -BatchSize $batchSize
    $successCount += $result[0]
    $errorCount += $result[1]
    
    # Add delay between batches
    if ($i + $batchSize - 1 -lt $targetCount) {
        Write-Host "Pausing between batches..." -ForegroundColor Yellow
        Start-Sleep -Seconds $delay
    }
}

# Verify download result
Write-Host "`nVerifying download result..." -ForegroundColor Cyan

$finalFiles = Get-ChildItem -Path $outputDir -Filter "*.jpg" -File
$finalCount = $finalFiles.Count

Write-Host "Download completed!" -ForegroundColor Green
Write-Host "Success: $successCount images" -ForegroundColor Green
Write-Host "Failed: $errorCount images" -ForegroundColor Red
Write-Host "Total images in folder: $finalCount" -ForegroundColor Yellow

Write-Host "`nImages are saved in: $outputDir" -ForegroundColor Cyan
Write-Host "You can now run the safe_rename_images.ps1 script to rename images to numerical format" -ForegroundColor Yellow

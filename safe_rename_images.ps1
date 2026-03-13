# Safe Image Rename Script
# Safely rename image files in numerical order, ensuring continuous numbering from 1

Write-Host "Starting safe image renaming process..." -ForegroundColor Cyan

$imageFolder = ".\downloaded_images"

# Check if folder exists
if (-not (Test-Path -Path $imageFolder)) {
    Write-Host "Error: Image folder does not exist!" -ForegroundColor Red
    exit 1
}

# Get all jpg files and sort numerically
$imageFiles = Get-ChildItem -Path $imageFolder -Filter "*.jpg" -File | 
    Sort-Object { [int]($_.BaseName -replace '\D+','') }

$totalCount = $imageFiles.Count

if ($totalCount -eq 0) {
    Write-Host "Error: No jpg files found!" -ForegroundColor Red
    exit 1
}

Write-Host "Found $totalCount images, preparing to rename..." -ForegroundColor Yellow

# Create a temporary folder for intermediate renaming
$tempFolder = Join-Path -Path $imageFolder -ChildPath "temp"
if (-not (Test-Path -Path $tempFolder)) {
    New-Item -Path $tempFolder -ItemType Directory | Out-Null
    Write-Host "Created temporary folder for safe renaming" -ForegroundColor Green
}

# Start renaming
$successCount = 0
$errorCount = 0

for ($i = 0; $i -lt $totalCount; $i++) {
    $oldFile = $imageFiles[$i]
    $newName = ($i + 1).ToString() + ".jpg"
    $tempPath = Join-Path -Path $tempFolder -ChildPath $newName
    
    try {
        # Copy file to temporary location with new name
        Copy-Item -Path $oldFile.FullName -Destination $tempPath -Force
        $successCount++
        
        # Show progress every 100 files
        if (($i + 1) % 100 -eq 0) {
            Write-Host "Copied $($i + 1)/$totalCount files to temporary location" -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to copy file $($oldFile.Name): $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

# If all files were copied successfully, replace original files
if ($errorCount -eq 0) {
    Write-Host "`nAll files copied successfully. Replacing original files..." -ForegroundColor Cyan
    
    # Remove original files
    $originalFiles = Get-ChildItem -Path $imageFolder -Filter "*.jpg" -File
    foreach ($file in $originalFiles) {
        Remove-Item -Path $file.FullName -Force
    }
    
    # Move files from temporary folder to main folder
    $tempFiles = Get-ChildItem -Path $tempFolder -Filter "*.jpg" -File
    foreach ($file in $tempFiles) {
        $destinationPath = Join-Path -Path $imageFolder -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destinationPath -Force
    }
    
    # Remove temporary folder
    Remove-Item -Path $tempFolder -Recurse -Force
    Write-Host "Temporary folder removed" -ForegroundColor Green
} else {
    Write-Host "`nSome files failed to copy. Original files preserved." -ForegroundColor Yellow
    # Remove temporary folder
    Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
}

# Verify renaming result
Write-Host "`nVerifying renaming result..." -ForegroundColor Cyan

# Reget files and check continuity
$renamedFiles = Get-ChildItem -Path $imageFolder -Filter "*.jpg" -File | 
    Sort-Object { [int]($_.BaseName -replace '\D+','') }

$renamedCount = $renamedFiles.Count

Write-Host "Found $renamedCount files after renaming" -ForegroundColor Yellow

# Check for missing numbers
$missingNumbers = @()
for ($i = 1; $i -le $renamedCount; $i++) {
    $expectedName = "$i.jpg"
    $fileExists = $renamedFiles | Where-Object { $_.Name -eq $expectedName }
    if (-not $fileExists) {
        $missingNumbers += $i
    }
}

if ($missingNumbers.Count -eq 0) {
    Write-Host "✅ All files successfully renamed with continuous numbering" -ForegroundColor Green
} else {
    Write-Host "❌ Found missing numbers: $($missingNumbers -join ', ')" -ForegroundColor Red
}

Write-Host "`nRenaming completed!" -ForegroundColor Green
Write-Host "Success: $successCount files" -ForegroundColor Green
Write-Host "Failed: $errorCount files" -ForegroundColor Red
Write-Host "`nUsage: After renaming, image files will be ordered as 1.jpg, 2.jpg, ..., N.jpg" -ForegroundColor Yellow
Write-Host "You can now open simple_image_viewer.html in your browser to view the updated images" -ForegroundColor Cyan

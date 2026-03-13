# Script to fix image naming and ensure sequential numbering

# Set variables
$imageDir = ".\downloaded_images"

Write-Host "Starting image name fix..."
Write-Host "=" * 60

# Get all image files and sort them numerically
$imageFiles = Get-ChildItem -Path $imageDir -Filter "*.jpg" | Sort-Object {[int]($_.Name.Split('.')[0])}

$totalImages = $imageFiles.Count
Write-Host "Found $totalImages image files"

if ($totalImages -eq 0) {
    Write-Host "No images found, exiting..."
    exit
}

# Rename images sequentially
$counter = 1
$renamedCount = 0

foreach ($file in $imageFiles) {
    $newName = "$counter.jpg"
    if ($file.Name -ne $newName) {
        $newPath = Join-Path -Path $imageDir -ChildPath $newName
        
        # Remove existing file with the same name if it exists
        if (Test-Path $newPath) {
            Remove-Item -Path $newPath -Force -ErrorAction SilentlyContinue
        }
        
        # Rename the file
        try {
            Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
            Write-Host "Renamed: $($file.Name) -> $newName"
            $renamedCount++
        } catch {
            Write-Warning "Failed to rename $($file.Name): $($_.Exception.Message)"
        }
    }
    $counter++
}

# Get final count of images
$finalImages = Get-ChildItem -Path $imageDir -Filter "*.jpg" | Sort-Object {[int]($_.Name.Split('.')[0])}
$finalCount = $finalImages.Count

Write-Host "=" * 60
Write-Host "Fix Results:"
Write-Host "Total Images: $totalImages"
Write-Host "Renamed Images: $renamedCount"
Write-Host "Final Images: $finalCount"

if ($finalCount -gt 0) {
    Write-Host "First image: $($finalImages[0].Name)"
    Write-Host "Last image: $($finalImages[-1].Name)"
}

Write-Host "=" * 60
Write-Host "Image name fix completed!"

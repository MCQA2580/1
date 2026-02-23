# Clean up invalid images and rename remaining images

# Use relative path to avoid encoding issues
$workingDir = ".\downloaded_images"

# Ensure the directory exists
if (-not (Test-Path $workingDir)) {
    Write-Host "ERROR: Directory $workingDir does not exist"
    exit 1
}

Set-Location $workingDir

# Record start time
$startTime = Get-Date
Write-Host "Starting image cleanup and renaming..."
Write-Host "Start time: $startTime"
Write-Host "=" * 50

# Check and clean up invalid images
$invalidImages = @()
$validImages = @()

# Get all image files
$imageFiles = Get-ChildItem -Name "*.jpg" | Sort-Object {[int]($_.Split('.')[0])}

Write-Host "Found $($imageFiles.Count) image files"
Write-Host "Checking image validity..."

# Check each image file
foreach ($file in $imageFiles) {
    try {
        # Check file size
        $fileInfo = Get-Item $file
        
        if ($fileInfo.Length -lt 1024) { # Files smaller than 1KB are considered invalid
            Write-Host "WARNING: Invalid image (too small): $file ($($fileInfo.Length) bytes)"
            $invalidImages += $file
        } else {
            # Try to read image header to verify
            $header = Get-Content -Path $file -Encoding Byte -TotalCount 4
            
            # Check JPEG file header
            if ($header[0] -eq 0xFF -and $header[1] -eq 0xD8) {
                $validImages += $file
            } else {
                Write-Host "WARNING: Invalid image (not JPEG format): $file"
                $invalidImages += $file
            }
        }
    } catch {
        Write-Host "WARNING: Invalid image (cannot access): $file"
        $invalidImages += $file
    }
}

# Clean up invalid images
if ($invalidImages.Count -gt 0) {
    Write-Host "=" * 50
    Write-Host "Deleting $($invalidImages.Count) invalid images..."
    
    foreach ($file in $invalidImages) {
        try {
            Remove-Item $file -Force
            Write-Host "SUCCESS: Deleted invalid image: $file"
        } catch {
            Write-Host "ERROR: Cannot delete: $file"
        }
    }
} else {
    Write-Host "SUCCESS: No invalid images found"
}

# Reget valid images and sort
$validImages = Get-ChildItem -Name "*.jpg" | Sort-Object {[int]($_.Split('.')[0])}

Write-Host "=" * 50
Write-Host "Valid images count: $($validImages.Count)"

# Rename images
if ($validImages.Count -gt 0) {
    Write-Host "Renaming images..."
    
    $counter = 1
    foreach ($file in $validImages) {
        $newName = "$counter.jpg"
        
        # Only rename if filename is different
        if ($file -ne $newName) {
            try {
                # Ensure new filename doesn't exist
                if (Test-Path $newName) {
                    Remove-Item $newName -Force
                }
                
                Rename-Item $file -NewName $newName
                Write-Host "SUCCESS: Renamed: $file -> $newName"
            } catch {
                Write-Host "ERROR: Cannot rename: $file"
            }
        }
        
        $counter++
    }
} else {
    Write-Host "WARNING: No valid images to rename"
}

# Verify after cleanup
$finalImages = Get-ChildItem -Name "*.jpg" | Sort-Object {[int]($_.Split('.')[0])}

Write-Host "=" * 50
Write-Host "Cleanup and renaming completed!"
Write-Host "Final image count: $($finalImages.Count)"

if ($finalImages.Count -gt 0) {
    Write-Host "First image: $($finalImages[0])"
    Write-Host "Last image: $($finalImages[-1])"
    
    # Check for missing numbers
    $expectedCount = $finalImages.Count
    $actualCount = ($finalImages[-1].Split('.')[0] -as [int])
    
    if ($expectedCount -eq $actualCount) {
        Write-Host "SUCCESS: All image numbers are sequential, from 1 to $expectedCount"
    } else {
        Write-Host "WARNING: Numbers are not sequential, expected $expectedCount images, actual numbering up to $actualCount"
    }
} else {
    Write-Host "WARNING: No images remaining"
}

# Record end time
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "End time: $endTime"
Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))"
Write-Host "=" * 50
Write-Host "Cleanup and renaming operation completed!"

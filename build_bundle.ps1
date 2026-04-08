
$html = Get-Content "index.html" -Raw
$css = Get-Content "css/style.css" -Raw
$js = Get-Content "js/main.js" -Raw

# Remove external links and replace with embedded content
$html = $html -replace '<link rel="stylesheet" href="css/style.css">', ("<style>`n" + $css + "`n</style>")
$html = $html -replace '<script src="js/main.js"></script>', ("<script>`n" + $js + "`n</script>")

# Find all images in assets
$assets = Get-ChildItem "assets" -Include *.png, *.jpg, *.jpeg, *.svg -File

foreach ($file in $assets) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $ext = $file.Extension.Replace(".", "").ToLower()
    if ($ext -eq "jpg") { $ext = "jpeg" }
    
    $mime = "image/$ext"
    if ($ext -eq "svg") { $mime = "image/svg+xml" }
    
    $base64String = "data:$mime;base64,$base64"
    $relPath = "assets/" + $file.Name
    
    # Escape path for regex if needed, but here simple replacement usually works for filenames
    $html = $html.Replace($relPath, $base64String)
}

$html | Set-Content "google_sites_bundle.html" -Encoding utf8
Write-Host "Bundle created: google_sites_bundle.html"

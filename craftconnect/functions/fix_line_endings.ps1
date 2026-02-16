$content = Get-Content -Raw index.js
$content = $content -replace "`r`n", "`n"
Set-Content -NoNewline -Encoding UTF8 -Path index.js -Value $content

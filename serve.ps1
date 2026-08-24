# Minimal static server for local preview. Supports Range requests, which
# media scrubbing needs — without them the video timeline cannot seek.
param([int]$Port = 8080)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$types = @{
  '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'
  '.js'='text/javascript; charset=utf-8'; '.json'='application/json'
  '.svg'='image/svg+xml'; '.png'='image/png'; '.jpg'='image/jpeg'
  '.jpeg'='image/jpeg'; '.webp'='image/webp'; '.ico'='image/x-icon'
  '.mp3'='audio/mpeg'; '.wav'='audio/wav'; '.m4a'='audio/mp4'
  '.mp4'='video/mp4'; '.webm'='video/webm'; '.pdf'='application/pdf'
  '.woff2'='font/woff2'; '.txt'='text/plain; charset=utf-8'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "serving $root on http://localhost:$Port/"

while ($listener.IsListening) {
  try { $ctx = $listener.GetContext() } catch { break }
  $res = $ctx.Response
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ($rel -eq '') { $rel = 'index.html' }
    $path = Join-Path $root ($rel -replace '/', '\')

    # Keep requests inside the served folder.
    $full = [System.IO.Path]::GetFullPath($path)
    if (-not $full.StartsWith([System.IO.Path]::GetFullPath($root))) { $res.StatusCode = 403; $res.Close(); continue }
    if (-not (Test-Path $full -PathType Leaf)) { $res.StatusCode = 404; $res.Close(); continue }

    $ext = [System.IO.Path]::GetExtension($full).ToLower()
    $res.ContentType = if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' }
    $res.Headers.Add('Cache-Control', 'no-store')
    $res.Headers.Add('Accept-Ranges', 'bytes')

    $bytes = [System.IO.File]::ReadAllBytes($full)
    $range = $ctx.Request.Headers['Range']
    if ($range -and $range -match 'bytes=(\d*)-(\d*)') {
      $from = if ($matches[1] -ne '') { [int64]$matches[1] } else { 0 }
      $to   = if ($matches[2] -ne '') { [int64]$matches[2] } else { $bytes.Length - 1 }
      if ($to -ge $bytes.Length) { $to = $bytes.Length - 1 }
      $len = $to - $from + 1
      $res.StatusCode = 206
      $res.Headers.Add('Content-Range', "bytes $from-$to/$($bytes.Length)")
      $res.ContentLength64 = $len
      $res.OutputStream.Write($bytes, $from, $len)
    } else {
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    }
  } catch {
    try { $res.StatusCode = 500 } catch {}
  } finally {
    try { $res.Close() } catch {}
  }
}

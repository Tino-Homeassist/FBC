# Fussball-Live-Center - kleiner lokaler Webserver (nur fuer diesen Computer erreichbar)
# Wird ueber "Start_mit_lokalem_Server.bat" gestartet. Fenster offen lassen, Beenden mit Strg+C.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8765
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try { $listener.Start() } catch {
  Write-Host "Der Server konnte nicht gestartet werden (Port $port belegt?)." -ForegroundColor Red
  Write-Host "Falls das Programm bereits laeuft: http://localhost:$port/Fussball_Live_Center.html"
  Start-Process "http://localhost:$port/Fussball_Live_Center.html"
  Read-Host "Eingabetaste zum Schliessen"; exit 1
}
$types = @{ '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'; '.json'='application/json; charset=utf-8';
            '.js'='text/javascript; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.png'='image/png'; '.jpg'='image/jpeg';
            '.svg'='image/svg+xml'; '.ico'='image/x-icon'; '.txt'='text/plain; charset=utf-8' }
Write-Host ""
Write-Host "  Fussball-Live-Center laeuft unter: http://localhost:$port/Fussball_Live_Center.html" -ForegroundColor Green
Write-Host "  Dieses Fenster bitte geoeffnet lassen. Beenden: Fenster schliessen oder Strg+C."
Write-Host ""
Start-Process "http://localhost:$port/Fussball_Live_Center.html"
$rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\') + '\'
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'Fussball_Live_Center.html' }
    $full = [IO.Path]::GetFullPath((Join-Path $root $rel))
    if ($full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $full -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($full)
      $ext = [IO.Path]::GetExtension($full).ToLower()
      $ctx.Response.ContentType = $(if ($types.ContainsKey($ext)) { $types[$ext] } else { 'application/octet-stream' })
      $ctx.Response.Headers.Add('Cache-Control', 'no-store')
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $msg = [Text.Encoding]::UTF8.GetBytes('Nicht gefunden')
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
  } catch { Write-Host "Fehler: $($_.Exception.Message)" } finally { $ctx.Response.Close() }
}

# Get a list of all .hex files in the directory
$hexFiles = Get-ChildItem -Path . -Filter *.hex

# If there are no existing .hex files, set $m to 1
if ($hexFiles.Count -eq 0) {
  $m = 1
}
else {
  # Find the hex file with the highest number and set $m to its value + 1
  $mostRecentFile = $hexFiles | Sort-Object { [int]($_.BaseName -replace "[^0-9]") } -Descending | Select-Object -First 1
  $m = [int]($mostRecentFile.BaseName -replace "[^0-9]")
  $m++
}

while ($true) {
  $fileName = "quihex$m.hex"
  if (Test-Path -Path $fileName) {
    Write-Host "$fileName already exists. Incrementing value of m."
    $m++
  }
  else {
    $lockFile = "$fileName.lock"
    try {
      New-Item -Path $lockFile -ItemType File | Out-Null
      go run bootstrap.go main.go $fileName
      $m++
    }
    finally {
      Remove-Item -Path $lockFile -Force
    }
  }
}
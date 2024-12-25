function Import-Settings {
  param($Programs, [bool]$Debug = $false)

  if ($Debug) {
    Write-Host -ForegroundColor Magenta "Contenuto di '`$Programs'"
    Write-Host -ForegroundColor Magenta $Programs
  }

  # per ogni programma
  foreach ($program in $Programs.keys) {
    if (Test-Path -Path "$program" -PathType Container) {
      $targetList = $Programs["$program"]

      # per ogni regola
      foreach ($target in $targetList) {
        $fileRegex = $target.fileLike
        $configPath = $target.configPath

        try {
          if (-not $Debug) {
            New-Item -ItemType Directory -Path "$configPath" -ErrorAction Stop
          } else {
            Write-Warning "Avrei creato la directory '$configPath'"
          }
        } catch [System.IO.IOException] {
          Write-Host -ForegroundColor Green "Il percorso '$configPath' esiste, non verrà sovrascritto"
        }

        $targetFiles = Get-ChildItem "$program"
          | Where-Object { $_.Name -match "$fileRegex" }
          | Select-Object -ExpandProperty Name

        # per ogni nome file che corrisponde alla regola
        foreach ($fileName in $targetFiles) {
          if (-not $Debug) {
            # TODO: Convertire in collegamento simbolico
            Copy-Item "$program\$fileName" "$configPath" -Force
          } else {
            Write-Warning "Avrei linkato '$program\$fileName' in '$configPath'"
          }
        }

      }

    } else {
      Write-Error "Impossibile trovare le impostazioni di '$program'"
    }
  }
}

Export-ModuleMember -Function Import-Settings

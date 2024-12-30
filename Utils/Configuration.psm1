function Import-Settings {
  param(
    $Programs,
    [string]$ConfigPath = '.',
    [bool]$Debug = $false
  )

  if ($Debug) {
    Write-Host -ForegroundColor Magenta "Contenuto di '`$Programs' = "
    ConvertTo-Json $Programs | Write-Host -ForegroundColor Magenta
    Write-Host -ForegroundColor Magenta "Contenuto di '`$ConfigPath' = "
    Write-Host -ForegroundColor Magenta $ConfigPath
  }

  if (-not (Test-Path -Path $ConfigPath -PathType Container)) {
    Write-Error "'$ConfigPath' non è una directory valida!"
    return
  }

  if ($Programs -eq $null) {
    Write-Error "Errore nella configurazione!"
    return
  }

  # per ogni programma
  foreach ($program in $Programs.keys) {
    if (Test-Path -Path "$ConfigPath\$program" -PathType Container) {
      $targetList = $Programs["$program"]
      $programSrcDir = $ConfigPath, $program -join '\'

      # per ogni regola
      foreach ($target in $targetList) {
        $fileRegex = $target.name
        $absRootDir = Get-Item -Path ("Env:\" + $target.root) | Select-Object -ExpandProperty Value
        $linkDestDir = $absRootDir, $target.destination -join '\'

        # crea la cartella se non esiste
        if (-not (Test-Path -PathType Container -Path $linkDestDir)) {
          if (-not $Debug) {
            New-Item -ItemType Directory -Path "$linkDestDir"
          } else {
            Write-Host -ForegroundColor Magenta "DEBUG: Avrei creato la directory '$linkDestDir'"
          }
        } else {
          Write-Warning "Il percorso '$linkDestDir' esiste, non verrà sovrascritto"
        }

        # ottieni nomi file
        $targetFiles = Resolve-Path "$programSrcDir"
          | Get-ChildItem
          | Where-Object { $_.Name -match "$fileRegex" }
          | Select-Object -ExpandProperty Name

        # per ogni nome file che corrisponde alla regola
        foreach ($fileName in $targetFiles) {
          $programAbsPath = Resolve-Path "$programSrcDir\$fileName"

          if (-not $Debug) {
            New-Item -ItemType SymbolicLink -Path "$linkDestDir\$fileName" -Value "$programAbsPath" -Force
          } else {
            Write-Host -ForegroundColor Magenta "DEBUG: Avrei linkato '$programAbsPath' a '$linkDestDir\$fileName'"
          }
        }

      }
    } else {
      Write-Error "Impossibile trovare le impostazioni di '$program'"
    }
  }
}

Export-ModuleMember -Function Import-Settings

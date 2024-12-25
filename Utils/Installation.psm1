function Install-Packages {
  param(
    [string]$PackageManager = "winget",
    [string[]]$PackageList,
    [bool]$Debug = $false
  )

  $cmdInfo = Get-Command "$PackageManager" -ErrorAction SilentlyContinue

  if ($cmdInfo -ne $null -and $cmdInfo.CommandType -eq 'Application') {
    $manager = $cmdInfo.Source

    switch ($cmdInfo.Name) {
      'winget.exe' {

        # aggiorna tutti i pacchetti già presenti

        $installCmd = "$manager upgrade --all --accept-package-agreements"

        if (-not $Debug) {
          Write-Host -ForegroundColor Green "Eseguo aggiornamento di tutti i pacchetti..."
          Invoke-Expression $installCmd
        } else {
          Write-Warning "Avrei eseguito aggiornamento di tutti i pacchetti"
          Write-Warning "CMD = '$installCmd'"
        }

        # installa i pacchetti mancanti
        foreach ($list in $PackageList) {
          if (Test-Path -Path "$list" -PathType Leaf) {
            $installList = "$manager import -i $list --accept-package-agreements"

            if (-not $Debug) {
              Write-Host -ForegroundColor Green "Installo i pacchetti da '$list'"
              Invoke-Expression $installList
            } else {
              Write-Warning "Avrei installato i pacchetti da '$list'"
              Write-Warning "CMD = '$installList'"
            }
          } else {
            Write-Error "Impossibile trovare il backup di winget"
          }
        }

        break
      }

      default {
        Write-Error "Package manager non supportato: " + $cmdInfo.Name
      }
    }

  } else {
    Write-Error "Impossibile trovare il comando: " + $cmdInfo.Name
  }
}

Export-ModuleMember -Function Install-Packages

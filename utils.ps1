function Download-And-Extract {
  param(
    [string]$Url,
    [string]$OutFile,
    [string]$DestinationPath
  )

  Invoke-WebRequest `
    -Uri $Url `
    -OutFile $OutFile

  Expand-Archive `
    -Path $OutFile `
    -DestinationPath $DestinationPath `
    -Force

  Remove-Item $OutFile -Force
}

function Download-And-Execute {
  param(
    [string]$Url,
    [string]$OutFile,
    [string[]]$ArgumentList
  )

  Invoke-WebRequest `
    -Uri $Url `
    -OutFile $OutFile
  
  if($OutFile -match '\.cmd$') {
    Start-Process `
      -FilePath $OutFile `
      -ArgumentList $ArgumentList `
      -Wait `
      -WindowStyle Hidden
  } else {
    Invoke-Expression "$OutFile $ArgumentList"
  }

  Remove-Item $OutFile -Force
}
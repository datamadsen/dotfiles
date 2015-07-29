param(
  [string]$partialWindowTitle
)
# We need Visual Basic to bring an application to front.
Add-Type -Assembly "Microsoft.VisualBasic"

if(-not($partialWindowTitle)) { 
  Write-Host "You must supply a value for -partialWindowTitle" 
  Exit
}

# Find the process id for the application that contains -partialWindowTitle
$processId = Get-Process `
  | Where-Object {$_.MainWindowTitle -match $partialWindowTitle } `
  | select -expand id

if(-not($processId)) { 
  Write-Host "process for $partialWindowTitle not found."
  Exit
} 

$processId | ForEach {
  # Bring the process to front.
  [Microsoft.VisualBasic.Interaction]::AppActivate($_)
  # Gently ask the application to close (so you're asked to save changes)
  Get-Process -Id $_ | %{ $_.closemainwindow()  } | out-null
}

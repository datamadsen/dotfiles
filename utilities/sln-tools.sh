#!/bin/bash

open() {
	local sln=$(upfind_sln);
	if [[ -n "$sln" ]]; then
		powershell Invoke-Item "$sln"
	else
		echo "No sln found. Change to a solution directory."
	fi
}

close() { 
	local pscmd_template='Get-Process | Where-Object {$_.MainWindowTitle -match "SLN - Microsoft Visual Studio" } | %{ Add-Type -Assembly "Microsoft.VisualBasic"; [Microsoft.VisualBasic.Interaction]::AppActivate($_.id); $_.CloseMainWindow() | out-null}'
	local pscmd=${pscmd_template/SLN/$(sln_name)}
	powershell "$pscmd"
}

sln_name() {
	echo $(upfind_sln | grep -Eo [^/]+$ | cut -d "." -f1)
}

upfind_sln() {
	while [[ $PWD != / ]]; do
		find "$PWD"/ -maxdepth 1 -name *.sln
		cd ..
	done
}

if [[ $1 =~ ^(open|close)$ ]]; then
  "$@"
else
  echo "Invalid subcommand $1" >&2
  exit 1
fi

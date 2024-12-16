<# : batch portion
@REM ----------------------------------------------------------------------------
@REM init idea zip file to current path
@REM ----------------------------------------------------------------------------

@set __ERROR_LOG__=[[31mERROR[0m]
@set __MVNW_CMD__=
@powershell.exe -noprofile "& {$scriptDir='%~dp0'; $script='%~nx0'; icm -ScriptBlock ([Scriptblock]::Create((Get-Content -Raw '%~f0'))) -NoNewScope}"
@if ERRORLEVEL 1 (echo %__ERROR_LOG__% An error occurred. Please fix the indicated issue before continuing. >&2 && exit /b 1)
@GOTO :EOF
: end batch / begin powershell #>

Write-Host "Hello From CMD & Power shell"
throw "eeeee"
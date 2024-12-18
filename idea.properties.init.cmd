<# : batch portion
@REM ----------------------------------------------------------------------------
@REM MIT License
@REM
@REM Copyright (c) 2024 Poshing
@REM
@REM Permission is hereby granted, free of charge, to any person obtaining a copy
@REM of this software and associated documentation files (the "Software"), to deal
@REM in the Software without restriction, including without limitation the rights
@REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@REM copies of the Software, and to permit persons to whom the Software is
@REM furnished to do so, subject to the following conditions:

@REM The above copyright notice and this permission notice shall be included in all
@REM copies or substantial portions of the Software.

@REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@REM SOFTWARE.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Updates the idea.properties file to set IntelliJ IDEA's key paths (config, system, plugins, log) 
@REM relative to its installation directory for easier management.
@REM
@REM Save to the bin directory of IntelliJ IDEA and run.
@REM
@REM version 1.0
@REM ----------------------------------------------------------------------------

@set __ERROR_LOG__=[[31mERROR[0m]
@set __INFO_LOG__=[[94mINFO[0m]
@set __MVNW_CMD__=
@set __POWER_SHELL_ERROR__=
@FOR /F "usebackq tokens=1* delims==" %%A IN (`powershell.exe -noprofile "& {$scriptDir='%~dp0'; $script='%~nx0'; icm -ScriptBlock ([Scriptblock]::Create((Get-Content -Raw '%~f0'))) -NoNewScope}"`) DO @(
  IF "%%A"=="PSHELL_MESSAGE" (set __POWER_SHELL_ERROR__=%%B) ELSE IF "%%B"=="" (echo %%A) ELSE (echo %%A=%%B)
)
@IF NOT "%__POWER_SHELL_ERROR__%"=="" @(
	echo %__ERROR_LOG__% %__POWER_SHELL_ERROR__%
    echo %__ERROR_LOG__% An error occurred. Please fix the indicated issue before continuing. >&2 && exit /b 1
)
@echo %__INFO_LOG__% idea properties replaced.
@GOTO :EOF
: end batch / begin powershell #>

$ideaPropertiesPath = Join-Path -Path $scriptDir -ChildPath "idea.properties" -ErrorAction SilentlyContinue
if (!(Test-Path -Path "$ideaPropertiesPath" -PathType Leaf)) {
	Write-Output "PSHELL_MESSAGE='$script' not in idea bin folder."
	exit $?
}

$ideaPropertiesContent = Get-Content -Path "$ideaPropertiesPath"
if (!$ideaPropertiesContent) {
	Write-Output "PSHELL_MESSAGE='$ideaPropertiesPath' is empty."
	exit $?
}
$ideaPropertiesOriginalLength = $ideaPropertiesContent.Length

#idea.home.path init
$ideaHomePath = $(Split-Path -Path $(Split-Path -Path "$scriptDir" -Parent) -Parent) -replace '\\', '/'
$ideaHomePathContent = "idea.home.path=$ideaHomePath"
$ideaPropertiesContent = $ideaPropertiesContent[0..2] + $ideaHomePathContent + $ideaPropertiesContent[3..($ideaPropertiesContent.Length - 1)]

# idea.config.path replace
$ideaConfigPathDefaultContent = '# idea.config.path=${user.home}/.IntelliJIdea/config'
$ideaConfigPathLineIndex = [array]::IndexOf($ideaPropertiesContent, $ideaConfigPathDefaultContent)
if ($ideaConfigPathLineIndex -eq -1) {
    Write-Output "PSHELL_MESSAGE='$ideaConfigPathDefaultContent' not found in '$ideaPropertiesPath'."
    exit $?
}
$ideaConfigPathReplaceContent = 'idea.config.path=${idea.home.path}/.IntelliJIdea/config'
$ideaPropertiesContent = $ideaPropertiesContent[0..$($ideaConfigPathLineIndex-1)] + $ideaConfigPathReplaceContent + $ideaPropertiesContent[$($ideaConfigPathLineIndex+1)..($ideaPropertiesContent.Length - 1)]

#idea.system.path replace
$ideaSystemPathDefaultContent = '# idea.system.path=${user.home}/.IntelliJIdea/system'
$ideaSystemPathLineIndex = [array]::IndexOf($ideaPropertiesContent, $ideaSystemPathDefaultContent)
if ($ideaSystemPathLineIndex -eq -1) {
    Write-Output "PSHELL_MESSAGE='$ideaSystemPathDefaultContent' not found in '$ideaPropertiesPath'."
    exit $?
}
$ideaSystemPathReplaceContent = 'idea.system.path=${idea.home.path}/.IntelliJIdea/system'
$ideaPropertiesContent = $ideaPropertiesContent[0..$($ideaSystemPathLineIndex-1)] + $ideaSystemPathReplaceContent + $ideaPropertiesContent[$($ideaSystemPathLineIndex+1)..($ideaPropertiesContent.Length - 1)]

#idea.plugins.path replace
$ideaPluginsPathDefaultContent = '# idea.plugins.path=${idea.config.path}/plugins'
$ideaPluginsPathLineIndex = [array]::IndexOf($ideaPropertiesContent, $ideaPluginsPathDefaultContent)
if ($ideaPluginsPathLineIndex -eq -1) {
    Write-Output "PSHELL_MESSAGE='$ideaPluginsPathDefaultContent' not found in '$ideaPropertiesPath'."
    exit $?
}
$ideaPluginsPathReplaceContent = 'idea.plugins.path=${idea.config.path}/plugins'
$ideaPropertiesContent = $ideaPropertiesContent[0..$($ideaPluginsPathLineIndex-1)] + $ideaPluginsPathReplaceContent + $ideaPropertiesContent[$($ideaPluginsPathLineIndex+1)..($ideaPropertiesContent.Length - 1)]

#idea.plugins.path replace
$ideaLogPathDefaultContent = '# idea.log.path=${idea.system.path}/log'
$ideaLogPathLineIndex = [array]::IndexOf($ideaPropertiesContent, $ideaLogPathDefaultContent)
if ($ideaLogPathLineIndex -eq -1) {
    Write-Output "PSHELL_MESSAGE='$ideaLogPathDefaultContent' not found in '$ideaPropertiesPath'."
    exit $?
}
$ideaLogPathReplaceContent = 'idea.log.path=${idea.system.path}/log'
$ideaPropertiesContent = $ideaPropertiesContent[0..$($ideaLogPathLineIndex-1)] + $ideaLogPathReplaceContent + $ideaPropertiesContent[$($ideaLogPathLineIndex+1)..($ideaPropertiesContent.Length - 1)]
#replaced content check
if ($($ideaPropertiesContent.Length - $ideaPropertiesOriginalLength) -ne 1) {
	Write-Output "PSHELL_MESSAGE='$ideaPropertiesPath' repleace length check error."
	exit $?
}

#backup original file
Rename-Item -Path "$ideaPropertiesPath" -NewName "idea.properties.original" -Force -ErrorAction SilentlyContinue | Out-Null
if (Test-Path -Path "$ideaPropertiesPath" -PathType Leaf) {
	Write-Output "PSHELL_MESSAGE='$ideaPropertiesPath' back up error."
	exit $?
}

#out new file utf8 with bom
#Out-File -FilePath "$ideaPropertiesPath" -InputObject $ideaPropertiesContent -Encoding utf8 -Force | Out-Null

#out new file utf8 no bom
Invoke-Command -ScriptBlock {
	[System.IO.File]::WriteAllLines("$ideaPropertiesPath", $ideaPropertiesContent, $(New-Object System.Text.UTF8Encoding $False))
} -ErrorAction SilentlyContinue
if (!(Test-Path -Path "$ideaPropertiesPath" -PathType Leaf)) {
	Write-Output "PSHELL_MESSAGE='$ideaPropertiesPath' replace error."
	exit $?
}

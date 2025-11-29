Param(
    [string]$Action = "menu"
)

$InstallDir = Join-Path $env:USERPROFILE "AppData\Local\Microsoft\WindowsApps"
$DataDir = Join-Path $env:USERPROFILE ".lithiumcli"
$CliDefaultName = "lithium"
$CliAltName = "lithium-cli"
$ManagerDefaultName = "lithium-manager"
$ManagerAltName = "lithium-cli-manager"

# Repositório público
$BaseUrl = "https://raw.githubusercontent.com/aencyorganization/lithiumcli/main"

function Download-File {
    param(
        [string]$Src,
        [string]$Dst
    )

    $url = "$BaseUrl/$Src"
    Invoke-WebRequest -Uri $url -OutFile $Dst -UseBasicParsing
}

function Ensure-Node {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "Erro: node não encontrado no PATH." -ForegroundColor Red
        Write-Host "Instale Node.js antes de continuar."
        exit 1
    }
}

function Ask-NameChoice {
    param(
        [string]$Prompt,
        [string]$Default,
        [string]$Alt
    )

    Write-Host ""
    Write-Host $Prompt
    Write-Host "1) $Default"
    Write-Host "2) $Alt"
    $answer = Read-Host "Escolha [1/2] (padrão 1)"
    switch ($answer) {
        "2" { return $Alt }
        default { return $Default }
    }
}

function Install-Cli {
    Ensure-Node

    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
    if (-not (Test-Path $DataDir)) {
        New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
    }

    $cliName = Ask-NameChoice "Nome do comando para o Lithium CLI?" $CliDefaultName $CliAltName
    $managerName = Ask-NameChoice "Nome do comando para o gerenciador do Lithium CLI?" $ManagerDefaultName $ManagerAltName

    Write-Host ""
    Write-Host "Instalando Lithium CLI e gerenciador..." -ForegroundColor Cyan

    $tmp = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()) -Force
    $binDir = Join-Path $tmp "bin"
    $srcDir = Join-Path $tmp "src"
    New-Item -ItemType Directory -Path $binDir,$srcDir -Force | Out-Null

    Download-File "bin/lithium.js" (Join-Path $binDir "lithium.js")
    Download-File "src/index.js" (Join-Path $srcDir "index.js")
    Download-File "VERSION" (Join-Path $tmp "VERSION")

    $cliPath = Join-Path $InstallDir "$cliName.cmd"
    "@echo off`r`nnode `"%~dp0..\..\$cliName.js`" %*" | Out-File -FilePath $cliPath -Encoding ASCII -Force

    $cliJsPath = Join-Path $InstallDir "$cliName.js"
    Copy-Item (Join-Path $binDir "lithium.js") $cliJsPath -Force

    Copy-Item (Join-Path $srcDir "index.js") (Join-Path $DataDir "index.js") -Force
    Copy-Item (Join-Path $tmp "VERSION") (Join-Path $DataDir "VERSION") -Force

    $managerPath = Join-Path $InstallDir "$managerName.ps1"
    @"
Param(
    [string]\$Action = "menu"
)

\$InstallDir = "$InstallDir"
\$DataDir = "$DataDir"
\$CliName = "$cliName"
\$BaseUrl = "$BaseUrl"

function Download-FileInner {
    param(
        [string]\$Src,
        [string]\$Dst
    )
    \$url = "\$BaseUrl/\$Src"
    Invoke-WebRequest -Uri \$url -OutFile \$Dst -UseBasicParsing
}

function Install-CliInner {
    Write-Host "Reinstalando Lithium CLI..." -ForegroundColor Cyan
    if (-not (Test-Path \$InstallDir)) { New-Item -ItemType Directory -Path \$InstallDir -Force | Out-Null }
    if (-not (Test-Path \$DataDir)) { New-Item -ItemType Directory -Path \$DataDir -Force | Out-Null }

    \$tmp = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()) -Force
    \$binDir = Join-Path \$tmp "bin"
    \$srcDir = Join-Path \$tmp "src"
    New-Item -ItemType Directory -Path \$binDir,\$srcDir -Force | Out-Null

    Download-FileInner "bin/lithium.js" (Join-Path \$binDir "lithium.js")
    Download-FileInner "src/index.js" (Join-Path \$srcDir "index.js")
    Download-FileInner "VERSION" (Join-Path \$tmp "VERSION")

    Copy-Item (Join-Path \$binDir "lithium.js") (Join-Path \$InstallDir "\$CliName.js") -Force
    Copy-Item (Join-Path \$srcDir "index.js") (Join-Path \$DataDir "index.js") -Force
    Copy-Item (Join-Path \$tmp "VERSION") (Join-Path \$DataDir "VERSION") -Force

    Write-Host "Instalação concluída." -ForegroundColor Green
}

function Update-CliInner {
    Write-Host "Verificando atualizações..." -ForegroundColor Cyan
    if (-not (Test-Path \$DataDir)) { New-Item -ItemType Directory -Path \$DataDir -Force | Out-Null }

    \$localVersion = ""
    if (Test-Path (Join-Path \$DataDir "VERSION")) {
        \$localVersion = (Get-Content (Join-Path \$DataDir "VERSION")).Trim()
    }

    \$tmpVer = New-TemporaryFile
    Download-FileInner "VERSION" \$tmpVer
    \$remoteVersion = (Get-Content \$tmpVer).Trim()

    if ([string]::IsNullOrEmpty(\$remoteVersion)) {
        Write-Host "Não foi possível obter versão remota." -ForegroundColor Red
        exit 1
    }

    if ((-not [string]::IsNullOrEmpty(\$localVersion)) -and \$localVersion -eq \$remoteVersion) {
        Write-Host "Você já está na versão mais recente (\$localVersion)." -ForegroundColor Green
        return
    }

    Write-Host "Atualizando da versão '\$localVersion' para '\$remoteVersion'..." -ForegroundColor Yellow
    Install-CliInner
}

function Uninstall-CliInner {
    Write-Host "Desinstalando Lithium CLI..." -ForegroundColor Yellow
    Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path \$InstallDir "\$CliName.js")
    Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path \$InstallDir "\$CliName.cmd")
    if (Test-Path \$DataDir) { Remove-Item -Recurse -Force \$DataDir }
    Write-Host "Remoção concluída." -ForegroundColor Green
}

switch (\$Action) {
    "install" { Install-CliInner }
    "update" { Update-CliInner }
    "uninstall" { Uninstall-CliInner }
    default {
        Write-Host "Uso: $managerName.ps1 [-Action install|update|uninstall]" -ForegroundColor Yellow
    }
}
"@ | Out-File -FilePath $managerPath -Encoding UTF8 -Force

    Write-Host ""
    Write-Host "Instalação concluída!" -ForegroundColor Green
    Write-Host "- CLI: $cliName (.cmd e .js em $InstallDir)"
    Write-Host "- Gerenciador: $managerName.ps1 em $InstallDir"
    Write-Host ""
    Write-Host "Adicione $InstallDir ao PATH se ainda não estiver."
}

function Uninstall-All {
    Write-Host "Desinstalando gerenciador e Lithium CLI..." -ForegroundColor Yellow
    foreach ($name in @($CliDefaultName, $CliAltName)) {
        Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $InstallDir "$name.js")
        Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $InstallDir "$name.cmd")
    }
    foreach ($name in @($ManagerDefaultName, $ManagerAltName)) {
        Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $InstallDir "$name.ps1")
    }
    if (Test-Path $DataDir) {
        Remove-Item -Recurse -Force $DataDir
    }
    Write-Host "Remoção concluída." -ForegroundColor Green
}

function Show-Menu {
    Write-Host "LithiumCLI - Gerenciador (Windows / PowerShell)"
    Write-Host "-----------------------------------------------"
    Write-Host "1) Instalar / reinstalar Lithium CLI"
    Write-Host "2) Atualizar Lithium CLI"
    Write-Host "3) Desinstalar Lithium CLI e gerenciador"
    Write-Host "q) Sair"
    Write-Host ""
}

switch ($Action) {
    "install" { Install-Cli }
    "update" {
        # Atualização é responsabilidade do gerenciador instalado
        if (Get-Command $ManagerDefaultName -ErrorAction SilentlyContinue) {
            & "$InstallDir\$ManagerDefaultName.ps1" -Action update
        } elseif (Get-Command $ManagerAltName -ErrorAction SilentlyContinue) {
            & "$InstallDir\$ManagerAltName.ps1" -Action update
        } else {
            Write-Host "Gerenciador não encontrado, executando instalação..." -ForegroundColor Yellow
            Install-Cli
        }
    }
    "uninstall" { Uninstall-All }
    default {
        Show-Menu
        $opt = Read-Host "Escolha uma opção"
        switch ($opt) {
            "1" { Install-Cli }
            "2" {
                if (Get-Command $ManagerDefaultName -ErrorAction SilentlyContinue) {
                    & "$InstallDir\$ManagerDefaultName.ps1" -Action update
                } elseif (Get-Command $ManagerAltName -ErrorAction SilentlyContinue) {
                    & "$InstallDir\$ManagerAltName.ps1" -Action update
                } else {
                    Write-Host "Gerenciador não encontrado, executando instalação..." -ForegroundColor Yellow
                    Install-Cli
                }
            }
            "3" { Uninstall-All }
            "q" { Write-Host "Saindo." }
            "Q" { Write-Host "Saindo." }
            default { Write-Host "Opção inválida." -ForegroundColor Red }
        }
    }
}



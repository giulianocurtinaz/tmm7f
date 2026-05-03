# ==============================================================
#  deploy.ps1 - Publica alterações da Terreira de Mãe Maria no GitHub
#  Uso:
#     .\deploy.ps1                          (mensagem padrão com data)
#     .\deploy.ps1 "minha mensagem aqui"   (mensagem customizada)
# ==============================================================

param(
    [string]$Mensagem = ""
)

# Forçar UTF-8 no console
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"

# Cores e símbolos
function Write-Step([string]$texto) {
    Write-Host ""
    Write-Host "==> $texto" -ForegroundColor Cyan
}
function Write-Ok([string]$texto)   { Write-Host "  [OK] $texto" -ForegroundColor Green }
function Write-Warn([string]$texto) { Write-Host "  [!]  $texto" -ForegroundColor Yellow }
function Write-Err([string]$texto)  { Write-Host "  [ERRO] $texto" -ForegroundColor Red }

# Vai para a pasta do script (raiz do projeto)
Set-Location $PSScriptRoot

Write-Host ""
Write-Host "================================================================" -ForegroundColor DarkCyan
Write-Host "  DEPLOY - Terreira de Mae Maria - Fraternidade Sete Flechas" -ForegroundColor DarkCyan
Write-Host "================================================================" -ForegroundColor DarkCyan

# 1) Verifica que estamos num repo git
Write-Step "Verificando repositorio Git..."
try {
    $null = git rev-parse --is-inside-work-tree 2>&1
    Write-Ok "Repositorio Git encontrado"
} catch {
    Write-Err "Esta pasta nao e um repositorio Git!"
    exit 1
}

# 2) Verifica branch
$branch = git rev-parse --abbrev-ref HEAD
Write-Step "Branch atual: $branch"
if ($branch -ne "main" -and $branch -ne "master") {
    Write-Warn "Voce esta na branch '$branch'. O site so publica de 'main' ou 'master'."
    $resp = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($resp -ne "s" -and $resp -ne "S") {
        Write-Host "Cancelado pelo usuario." -ForegroundColor Yellow
        exit 0
    }
}

# 3) Mostra arquivos modificados
Write-Step "Arquivos com alteracoes locais:"
$status = git status --short
if (-not $status) {
    Write-Warn "Nenhuma alteracao para publicar. Tudo esta sincronizado."
    exit 0
}
git status --short | ForEach-Object {
    Write-Host "  $_" -ForegroundColor Gray
}

# 4) Confirma com o usuario
Write-Host ""
$resp = Read-Host "Deseja adicionar TODOS estes arquivos e publicar? (s/N)"
if ($resp -ne "s" -and $resp -ne "S") {
    Write-Host "Cancelado pelo usuario. Nada foi alterado." -ForegroundColor Yellow
    exit 0
}

# 5) Define mensagem do commit
if ([string]::IsNullOrWhiteSpace($Mensagem)) {
    $dataAgora = Get-Date -Format "dd/MM/yyyy HH:mm"
    $Mensagem = "Atualizacao do site em $dataAgora"
}

# 6) Adiciona, comita e empurra
Write-Step "Adicionando arquivos ao stage..."
git add .
Write-Ok "Arquivos adicionados"

Write-Step "Criando commit..."
Write-Host "  Mensagem: $Mensagem" -ForegroundColor Gray
git commit -m "$Mensagem"
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha ao criar commit. Verifique se ha conflitos ou problemas."
    exit 1
}
Write-Ok "Commit criado"

Write-Step "Enviando para o GitHub (origin/$branch)..."
git push origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha ao fazer push. Possiveis causas:"
    Write-Err "  - Sem internet"
    Write-Err "  - Autenticacao do GitHub nao configurada (use GitHub CLI ou Desktop)"
    Write-Err "  - Branch desatualizada (rode 'git pull origin $branch' primeiro)"
    exit 1
}
Write-Ok "Push concluido"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  PUBLICADO COM SUCESSO!" -ForegroundColor Green
Write-Host "  O site sera atualizado em https://www.maemariaseteflechas.com.br" -ForegroundColor Green
Write-Host "  em 1-2 minutos." -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

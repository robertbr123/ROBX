@echo off
echo 🚀 Iniciando ROBX Trading Bot...
echo.

REM Verificar se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python não encontrado. Por favor, instale Python 3.8+ 
    pause
    exit /b 1
)

REM Verificar se Node.js está instalado
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js não encontrado. Por favor, instale Node.js 16+
    pause
    exit /b 1
)

echo ✅ Python e Node.js encontrados

REM Configurar ambiente Python
echo.
echo 📦 Configurando ambiente Python...
cd backend
pip install -r ../requirements.txt
if errorlevel 1 (
    echo ❌ Erro ao instalar dependências Python
    pause
    exit /b 1
)

echo ✅ Dependências Python instaladas

REM Configurar ambiente Node.js
echo.
echo 📦 Configurando ambiente React...
cd ../frontend
call npm install
if errorlevel 1 (
    echo ❌ Erro ao instalar dependências Node.js
    pause
    exit /b 1
)

echo ✅ Dependências React instaladas

REM Criar arquivo .env se não existir
cd ..
if not exist ".env" (
    echo 📝 Criando arquivo .env...
    copy .env.example .env
)

echo.
echo 🎉 Setup concluído com sucesso!
echo.
echo Para executar o ROBX Trading Bot:
echo 1. Backend: run-backend.bat
echo 2. Frontend: run-frontend.bat
echo.
pause
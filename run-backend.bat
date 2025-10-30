@echo off
echo 🔧 Iniciando Backend ROBX...
echo.

REM Verificar se está no diretório correto
if not exist "backend\main.py" (
    echo ❌ Arquivo main.py não encontrado. Execute a partir do diretório raiz do projeto.
    pause
    exit /b 1
)

REM Navegar para o diretório backend
cd backend

REM Verificar se as dependências estão instaladas
python -c "import fastapi" >nul 2>&1
if errorlevel 1 (
    echo ❌ FastAPI não encontrado. Execute setup.bat primeiro.
    pause
    exit /b 1
)

echo ✅ Dependências verificadas
echo.
echo 🚀 Iniciando servidor FastAPI na porta 8000...
echo 📊 API Docs: http://localhost:8000/docs
echo 🔗 WebSocket: ws://localhost:8000/ws
echo.
echo Pressione Ctrl+C para parar o servidor
echo.

REM Executar o servidor
python main.py
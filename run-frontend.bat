@echo off
echo 🎨 Iniciando Frontend ROBX...
echo.

REM Verificar se está no diretório correto
if not exist "frontend\package.json" (
    echo ❌ package.json não encontrado. Execute a partir do diretório raiz do projeto.
    pause
    exit /b 1
)

REM Navegar para o diretório frontend
cd frontend

REM Verificar se as dependências estão instaladas
if not exist "node_modules" (
    echo ❌ Dependências não instaladas. Execute setup.bat primeiro.
    pause
    exit /b 1
)

echo ✅ Dependências verificadas
echo.
echo 🚀 Iniciando servidor React na porta 3000...
echo 🌐 Interface: http://localhost:3000
echo.
echo Pressione Ctrl+C para parar o servidor
echo.

REM Executar o servidor de desenvolvimento
call npm start
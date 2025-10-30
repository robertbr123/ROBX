#!/bin/bash

echo "🚀 ROBX SIMPLES - Sistema que FUNCIONA!"
echo "======================================="
echo

echo "📁 Criando estrutura básica..."

# Criar diretórios simples
mkdir -p api
mkdir -p web

echo "🐍 Criando API simples..."

# API simples com FastAPI
cat > api/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import yfinance as yf
from datetime import datetime

app = FastAPI(title="ROBX API Simples")

# CORS simples
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "ROBX API funcionando!", "time": datetime.now()}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/stock/{symbol}")
def get_stock(symbol: str):
    try:
        ticker = yf.Ticker(f"{symbol}.SA")  # B3 stocks
        info = ticker.info
        hist = ticker.history(period="1d")
        
        return {
            "symbol": symbol,
            "name": info.get("longName", "N/A"),
            "price": float(hist['Close'].iloc[-1]) if not hist.empty else 0,
            "change": float(hist['Close'].iloc[-1] - hist['Close'].iloc[0]) if len(hist) > 1 else 0,
            "volume": int(hist['Volume'].iloc[-1]) if not hist.empty else 0
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    print("🚀 Iniciando ROBX API em http://localhost:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

echo "🌐 Criando frontend simples..."

# Frontend HTML simples que funciona
cat > web/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ROBX Trading Bot</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            padding: 40px 0;
        }
        
        .header h1 {
            font-size: 3em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        
        .trading-panel {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 30px;
            margin: 20px 0;
            backdrop-filter: blur(10px);
        }
        
        .input-group {
            margin: 20px 0;
        }
        
        .input-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .input-group input {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            margin-bottom: 10px;
        }
        
        .btn {
            background: #4CAF50;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            margin: 10px 5px;
            transition: background 0.3s;
        }
        
        .btn:hover {
            background: #45a049;
        }
        
        .btn-secondary {
            background: #2196F3;
        }
        
        .btn-secondary:hover {
            background: #1976D2;
        }
        
        .stock-info {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            display: none;
        }
        
        .stock-info.show {
            display: block;
            animation: fadeIn 0.5s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .stock-price {
            font-size: 2em;
            font-weight: bold;
            color: #4CAF50;
        }
        
        .stock-change {
            font-size: 1.2em;
            margin: 10px 0;
        }
        
        .positive { color: #4CAF50; }
        .negative { color: #f44336; }
        
        .loading {
            text-align: center;
            padding: 20px;
        }
        
        .error {
            background: rgba(244, 67, 54, 0.2);
            border: 1px solid #f44336;
            color: #ffcdd2;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
        }
        
        .success {
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid #4CAF50;
            color: #c8e6c9;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <header class="header">
            <h1>🤖 ROBX Trading Bot</h1>
            <p>Sistema Simples de Trading B3</p>
        </header>
        
        <div class="trading-panel">
            <h2>📈 Consultar Ação</h2>
            
            <div class="input-group">
                <label for="stockSymbol">Código da Ação (ex: PETR4, VALE3, ITUB4):</label>
                <input type="text" id="stockSymbol" placeholder="Digite o código da ação" maxlength="6">
            </div>
            
            <button class="btn" onclick="getStock()">🔍 Buscar Ação</button>
            <button class="btn btn-secondary" onclick="clearResults()">🗑️ Limpar</button>
            
            <div id="loading" class="loading" style="display: none;">
                <p>⏳ Carregando dados...</p>
            </div>
            
            <div id="error" class="error" style="display: none;"></div>
            <div id="success" class="success" style="display: none;"></div>
            
            <div id="stockInfo" class="stock-info">
                <h3 id="stockName">Nome da Ação</h3>
                <div class="stock-price" id="stockPrice">R$ 0,00</div>
                <div class="stock-change" id="stockChange">Variação: R$ 0,00</div>
                <p><strong>Volume:</strong> <span id="stockVolume">0</span></p>
                <p><strong>Última atualização:</strong> <span id="lastUpdate"></span></p>
            </div>
        </div>
        
        <div class="trading-panel">
            <h2>📊 Status da API</h2>
            <button class="btn btn-secondary" onclick="checkAPI()">🔄 Verificar API</button>
            <div id="apiStatus"></div>
        </div>
    </div>

    <script>
        const API_URL = 'http://localhost:8000';
        
        async function getStock() {
            const symbol = document.getElementById('stockSymbol').value.trim().toUpperCase();
            
            if (!symbol) {
                showError('Por favor, digite um código de ação');
                return;
            }
            
            showLoading(true);
            hideMessages();
            
            try {
                const response = await fetch(`${API_URL}/stock/${symbol}`);
                const data = await response.json();
                
                if (data.error) {
                    showError(`Erro: ${data.error}`);
                } else {
                    displayStock(data);
                    showSuccess('Dados carregados com sucesso!');
                }
            } catch (error) {
                showError('Erro ao conectar com a API. Certifique-se de que o backend está rodando.');
            } finally {
                showLoading(false);
            }
        }
        
        function displayStock(data) {
            document.getElementById('stockName').textContent = `${data.symbol} - ${data.name}`;
            document.getElementById('stockPrice').textContent = `R$ ${data.price.toFixed(2)}`;
            
            const change = data.change;
            const changeElement = document.getElementById('stockChange');
            changeElement.textContent = `Variação: R$ ${change.toFixed(2)} (${change >= 0 ? '+' : ''}${((change / (data.price - change)) * 100).toFixed(2)}%)`;
            changeElement.className = `stock-change ${change >= 0 ? 'positive' : 'negative'}`;
            
            document.getElementById('stockVolume').textContent = data.volume.toLocaleString();
            document.getElementById('lastUpdate').textContent = new Date().toLocaleString();
            
            document.getElementById('stockInfo').classList.add('show');
        }
        
        async function checkAPI() {
            try {
                const response = await fetch(`${API_URL}/health`);
                const data = await response.json();
                
                if (data.status === 'ok') {
                    document.getElementById('apiStatus').innerHTML = '<div class="success">✅ API funcionando normalmente</div>';
                } else {
                    document.getElementById('apiStatus').innerHTML = '<div class="error">⚠️ API com problemas</div>';
                }
            } catch (error) {
                document.getElementById('apiStatus').innerHTML = '<div class="error">❌ API não está respondendo. Inicie o backend!</div>';
            }
        }
        
        function clearResults() {
            document.getElementById('stockSymbol').value = '';
            document.getElementById('stockInfo').classList.remove('show');
            hideMessages();
            document.getElementById('apiStatus').innerHTML = '';
        }
        
        function showLoading(show) {
            document.getElementById('loading').style.display = show ? 'block' : 'none';
        }
        
        function showError(message) {
            const errorDiv = document.getElementById('error');
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
        }
        
        function showSuccess(message) {
            const successDiv = document.getElementById('success');
            successDiv.textContent = message;
            successDiv.style.display = 'block';
        }
        
        function hideMessages() {
            document.getElementById('error').style.display = 'none';
            document.getElementById('success').style.display = 'none';
        }
        
        // Permitir busca com Enter
        document.getElementById('stockSymbol').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                getStock();
            }
        });
        
        // Verificar API ao carregar a página
        window.onload = function() {
            checkAPI();
        };
    </script>
</body>
</html>
EOF

echo "📋 Criando dependências simples..."

# Requirements simples
cat > requirements.txt << 'EOF'
fastapi
uvicorn
yfinance
python-dotenv
EOF

echo "🚀 Criando scripts simples..."

# Script para rodar API
cat > start-api.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando ROBX API..."

# Instalar dependências se necessário
if [ ! -d "venv" ]; then
    echo "📦 Criando ambiente virtual..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

echo "✅ Iniciando API em http://localhost:8000"
cd api
python main.py
EOF

# Script para rodar frontend
cat > start-web.sh << 'EOF'
#!/bin/bash
echo "🌐 Iniciando ROBX Frontend..."

if command -v python3 &> /dev/null; then
    echo "✅ Abrindo frontend em http://localhost:3000"
    cd web
    python3 -m http.server 3000
else
    echo "❌ Python não encontrado. Abra web/index.html manualmente no navegador"
fi
EOF

# Script para rodar tudo
cat > start-all.sh << 'EOF'
#!/bin/bash
echo "🚀 ROBX - Iniciando TUDO!"

# Iniciar API em background
echo "🔧 Iniciando API..."
./start-api.sh &
API_PID=$!

sleep 3

# Iniciar frontend
echo "🌐 Iniciando Frontend..."
./start-web.sh &
WEB_PID=$!

echo ""
echo "✅ ROBX FUNCIONANDO!"
echo "📊 API: http://localhost:8000"
echo "🌐 Web: http://localhost:3000"
echo ""
echo "Para parar: Ctrl+C"

# Aguardar
wait
EOF

# Tornar scripts executáveis
chmod +x *.sh

echo ""
echo "🎉 ROBX SIMPLES CRIADO!"
echo "======================"
echo ""
echo "📁 Estrutura:"
echo "   api/main.py     - API FastAPI simples"
echo "   web/index.html  - Frontend HTML/JS puro"
echo "   requirements.txt - Dependências mínimas"
echo ""
echo "🚀 Para usar:"
echo "   ./start-all.sh   - Inicia tudo"
echo "   ./start-api.sh   - Apenas API"
echo "   ./start-web.sh   - Apenas frontend"
echo ""
echo "🌐 Acesse:"
echo "   http://localhost:3000 - Interface"
echo "   http://localhost:8000 - API"
echo ""
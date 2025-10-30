"""
WebSocket Manager
Gerencia conexões WebSocket para dados em tempo real
"""

from fastapi import WebSocket
from typing import List, Dict
import json
import asyncio

class WebSocketManager:
    """Gerenciador de conexões WebSocket"""
    
    def __init__(self):
        # Conexões por símbolo
        self.symbol_connections: Dict[str, List[WebSocket]] = {}
        
        # Conexões para sinais de trading
        self.signal_connections: List[WebSocket] = []
        
        # Conexões ativas
        self.active_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket, symbol: str):
        """Conecta um WebSocket para um símbolo específico"""
        await websocket.accept()
        
        if symbol not in self.symbol_connections:
            self.symbol_connections[symbol] = []
        
        self.symbol_connections[symbol].append(websocket)
        self.active_connections.append(websocket)
        
        print(f"📡 WebSocket connected for {symbol}. Total connections: {len(self.active_connections)}")
    
    async def connect_signals(self, websocket: WebSocket):
        """Conecta um WebSocket para sinais de trading"""
        await websocket.accept()
        
        self.signal_connections.append(websocket)
        self.active_connections.append(websocket)
        
        print(f"🔔 Signal WebSocket connected. Total signal connections: {len(self.signal_connections)}")
    
    def disconnect(self, websocket: WebSocket, symbol: str):
        """Desconecta um WebSocket de um símbolo"""
        try:
            if symbol in self.symbol_connections:
                self.symbol_connections[symbol].remove(websocket)
                
                # Remove symbol if no connections left
                if not self.symbol_connections[symbol]:
                    del self.symbol_connections[symbol]
            
            if websocket in self.active_connections:
                self.active_connections.remove(websocket)
                
            print(f"📡 WebSocket disconnected for {symbol}. Total connections: {len(self.active_connections)}")
            
        except ValueError:
            pass  # WebSocket was already removed
    
    def disconnect_signals(self, websocket: WebSocket):
        """Desconecta um WebSocket de sinais"""
        try:
            if websocket in self.signal_connections:
                self.signal_connections.remove(websocket)
            
            if websocket in self.active_connections:
                self.active_connections.remove(websocket)
                
            print(f"🔔 Signal WebSocket disconnected. Total signal connections: {len(self.signal_connections)}")
            
        except ValueError:
            pass  # WebSocket was already removed
    
    async def send_to_symbol(self, symbol: str, data: dict):
        """Envia dados para todas as conexões de um símbolo"""
        if symbol not in self.symbol_connections:
            return
        
        # Get list of connections (copy to avoid modification during iteration)
        connections = self.symbol_connections[symbol].copy()
        
        # Remove failed connections
        failed_connections = []
        
        for connection in connections:
            try:
                await connection.send_text(json.dumps(data))
            except Exception as e:
                print(f"❌ Failed to send data to {symbol} connection: {e}")
                failed_connections.append(connection)
        
        # Clean up failed connections
        for connection in failed_connections:
            self.disconnect(connection, symbol)
    
    async def send_signals(self, data: dict):
        """Envia sinais para todas as conexões de sinais"""
        if not self.signal_connections:
            return
        
        # Get list of connections (copy to avoid modification during iteration)
        connections = self.signal_connections.copy()
        
        # Remove failed connections
        failed_connections = []
        
        for connection in connections:
            try:
                await connection.send_text(json.dumps(data))
            except Exception as e:
                print(f"❌ Failed to send signal: {e}")
                failed_connections.append(connection)
        
        # Clean up failed connections
        for connection in failed_connections:
            self.disconnect_signals(connection)
    
    async def broadcast_to_all(self, data: dict):
        """Envia dados para todas as conexões ativas"""
        if not self.active_connections:
            return
        
        # Get list of connections (copy to avoid modification during iteration)
        connections = self.active_connections.copy()
        
        # Remove failed connections
        failed_connections = []
        
        for connection in connections:
            try:
                await connection.send_text(json.dumps(data))
            except Exception as e:
                print(f"❌ Failed to broadcast: {e}")
                failed_connections.append(connection)
        
        # Clean up failed connections
        for connection in failed_connections:
            if connection in self.active_connections:
                self.active_connections.remove(connection)
    
    def get_connection_stats(self) -> dict:
        """Retorna estatísticas das conexões"""
        return {
            "total_connections": len(self.active_connections),
            "signal_connections": len(self.signal_connections),
            "symbol_connections": {
                symbol: len(connections) 
                for symbol, connections in self.symbol_connections.items()
            },
            "active_symbols": list(self.symbol_connections.keys())
        }
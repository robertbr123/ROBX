const path = require('path');

module.exports = {
  webpack: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
    configure: (webpackConfig, { env, paths }) => {
      // Configurações específicas para desenvolvimento
      if (env === 'development') {
        // Fix para o erro de allowedHosts e deprecation warnings
        if (webpackConfig.devServer) {
          webpackConfig.devServer = {
            ...webpackConfig.devServer,
            allowedHosts: 'all',
            host: '0.0.0.0',
            port: 3000,
            client: {
              webSocketURL: 'auto://0.0.0.0:0/ws'
            },
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
              'Access-Control-Allow-Headers': 'X-Requested-With, content-type, Authorization'
            },
            // Nova sintaxe para middleware (resolve deprecation warning)
            setupMiddlewares: (middlewares, devServer) => {
              if (!devServer) {
                throw new Error('webpack-dev-server is not defined');
              }
              
              // Middleware customizado pode ser adicionado aqui
              return middlewares;
            },
            // Remover configurações depreciadas
            onBeforeSetupMiddleware: undefined,
            onAfterSetupMiddleware: undefined,
          };
        }
      }
      
      return webpackConfig;
    },
  },
  devServer: (devServerConfig, { env, paths, proxy, allowedHost }) => {
    // Configuração moderna do dev server
    return {
      ...devServerConfig,
      allowedHosts: 'all',
      host: '0.0.0.0',
      port: 3000,
      client: {
        webSocketURL: 'auto://0.0.0.0:0/ws',
        overlay: {
          errors: true,
          warnings: false,
        },
      },
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
        'Access-Control-Allow-Headers': 'X-Requested-With, content-type, Authorization'
      },
      // Nova sintaxe recomendada
      setupMiddlewares: (middlewares, devServer) => {
        if (!devServer) {
          throw new Error('webpack-dev-server is not defined');
        }
        
        // Log de inicialização
        devServer.app.get('/api/health', (req, res) => {
          res.json({ status: 'Frontend dev server running' });
        });
        
        return middlewares;
      },
      // Configurações adicionais para evitar warnings
      compress: true,
      historyApiFallback: true,
      hot: true,
      liveReload: false, // Usar apenas hot reload
    };
  },
  eslint: {
    enable: false, // Desabilitar ESLint temporariamente para evitar problemas
  },
};
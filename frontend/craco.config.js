const path = require('path');

module.exports = {
  webpack: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
    configure: (webpackConfig, { env, paths }) => {
      // Configurações específicas para desenvolvimento
      if (env === 'development') {
        // Fix para o erro de allowedHosts
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
            }
          };
        }
      }
      
      return webpackConfig;
    },
  },
  devServer: {
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
    }
  },
  eslint: {
    enable: false, // Desabilitar ESLint temporariamente para evitar problemas
  },
};
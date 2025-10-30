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
          const devServerConfig = {
            ...webpackConfig.devServer,
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
            compress: true,
            historyApiFallback: true,
            hot: true,
          };

          // Adicionar setupMiddlewares se webpack dev server suportar
          try {
            devServerConfig.setupMiddlewares = (middlewares, devServer) => {
              if (!devServer) {
                throw new Error('webpack-dev-server is not defined');
              }
              return middlewares;
            };
          } catch (error) {
            // Fallback para versões antigas
            console.log('Using legacy middleware configuration');
          }

          webpackConfig.devServer = devServerConfig;
        }
      }
      
      return webpackConfig;
    },
  },
  devServer: (devServerConfig, { env, paths, proxy, allowedHost }) => {
    // Configuração robusta do dev server
    const config = {
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
      compress: true,
      historyApiFallback: true,
      hot: true,
      liveReload: false,
    };

    // Adicionar setupMiddlewares de forma segura
    try {
      config.setupMiddlewares = (middlewares, devServer) => {
        if (!devServer) {
          throw new Error('webpack-dev-server is not defined');
        }
        
        // Health check endpoint
        if (devServer.app) {
          devServer.app.get('/api/health', (req, res) => {
            res.json({ status: 'Frontend dev server running' });
          });
        }
        
        return middlewares;
      };
    } catch (error) {
      console.log('setupMiddlewares not available, using legacy configuration');
    }

    return config;
  },
  eslint: {
    enable: false, // Desabilitar ESLint para evitar problemas
  },
};
Rails.application.config.middleware.use OmniAuth::Builder do
  provider  :developer if Rails.env.development?
  provider  :openid_connect,
            scope: ['openid', 'profile', 'email'],
            issuer: ENV['OIDC_ISSUER'],
            discovery: true,
            client_options: {
              port: 443,
              scheme: 'https',
              host: ENV["OIDC_HOSTNAME"],
              authorization_endpoint: ENV['OIDC_AUTHORIZATION_ENDPOINT'],
              token_endpoint: ENV['OIDC_TOKEN_ENDPOINT'],
              userinfo_endpoint: ENV['OIDC_USERINFO_ENDPOINT'],
              identifier: ENV["OIDC_IDENTIFIER"],
              secret: ENV["OIDC_SECRET"],
              redirect_uri: ENV['OIDC_REDIRECT_URI']
            }
end
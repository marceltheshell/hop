#
# Sidekiq config
#
app_name      = File.basename( Rails.root.to_s )
env_name      = Rails.env.to_s
namespace     = "#{app_name}-#{env_name}"

Sidekiq::Extensions.enable_delay! #enables delayed email delivery

Sidekiq.configure_client do |config|
  config.redis = { :namespace => namespace }
end

Sidekiq.configure_server do |config|
  config.redis  = { :namespace => namespace }
end

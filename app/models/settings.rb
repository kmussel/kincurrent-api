class Settings < Settingslogic
  source "config/application.yml"
  namespace Sinatra::Application.settings.environment.to_s
end
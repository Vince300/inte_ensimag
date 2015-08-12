JsRoutes.setup do |config|
  config.include = [ /^(teams|events|rewards|stats)$/ ]

  if Rails.env == 'production'
    config.prefix = '/inte'
  end
end
if Rails.env.development?
  Rails.application.middleware.use( Oink::Middleware, logger: Hodel3000CompliantLogger.new(STDOUT) )
end
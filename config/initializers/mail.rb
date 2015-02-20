if Rails.env.development? || Rails.env.test?
  ActionMailer::Base.register_interceptor(Interceptors::DevelopmentMailInterceptor)
end

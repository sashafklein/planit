if Rails.env.development?
  ActionMailer::Base.register_interceptor(Interceptors::DevelopmentMailInterceptor)
end

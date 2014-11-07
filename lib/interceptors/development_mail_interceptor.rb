module Interceptors
  class DevelopmentMailInterceptor
    def self.delivering_email(message)
      message.to =  `git config --get user.email`.strip
      message.bcc =  nil if message.bcc.present?
      message.cc =  nil if message.cc.present?
    end
  end
end
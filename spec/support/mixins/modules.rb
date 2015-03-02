module Features
  include Warden::Test::Helpers
  Warden.test_mode!
  
  def sign_in(user)
    login_as(user, scope: :user)
  end
end

module Controllers
  def response_body
    body = JSON.parse(response.body)
    body.to_super
  end
end

module Mock
  def disable_webmock(&block)
    WebMock.disable!
    yield
    WebMock.enable!
  end
end
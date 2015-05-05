module Features
  include Warden::Test::Helpers
  Warden.test_mode!
  
  def sign_in(user)
    login_as(user, scope: :user)
  end

  def expect_flash(msg)
    within '#flash' do
      expect( page ).to have_content msg
    end
  end

  def full_path
    uri = URI.parse(current_url)
    "#{uri.path}?#{uri.query}"
  end

  def wait_for(selector:, limit: 10)
    if Nokogiri.parse(html).css(selector).present?
      true
    elsif limit <= 0
      raise "Couldn't find #{selector} in \n\n#{html}"
    else
      sleep 0.2
      wait_for(selector: selector, limit: limit - 0.2)
    end
  end

  def ng_hidden(root: nil, selector:)
    root ||= Nokogiri.parse(html)
    root.css(selector).select{ |e| e.attributes.find{ |k, v| k == 'class'}.last.value.include?("ng-hide") }
  end

  def ng_shown(root: nil, selector:)
    root ||= Nokogiri.parse(html)
    root.css(selector).select{ |e| !e.attributes.find{ |k, v| k == 'class'}.last.value.include?("ng-hide") }
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

module Universal
  def email_text(subject: "Welcome to Planit Beta!")
    email_by_subject(subject).parts.first.body.raw_source
  end

  def email_by_subject(subject)
    delivered_emails.find{ |d| d.subject == subject }
  end

  def delivered_emails
    ActionMailer::Base.deliveries
  end
end
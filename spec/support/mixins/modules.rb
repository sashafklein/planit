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

  def wait_for(selector: , limit: 10)
    recursive_wait_for selector: selector, limit: ( limit * ( Env.test_sleep_multiple || 1 ).to_i )
  end

  def full_path
    uri = URI.parse(current_url)
    "#{uri.path}?#{uri.query}"
  end

  def ng_hidden(root: nil, selector:)
    root ||= Nokogiri.parse(html)
    root.css(selector).select{ |e| classes_for( e ).include?("ng-hide") }
  end

  def ng_shown(root: nil, selector:)
    root ||= Nokogiri.parse(html)
    root.css(selector).select{ |e| !classes_for( e ).include?("ng-hide") }
  end

  def classes_for(selector)
    if selector.is_a?(String)
      classes_for Nokogiri.parse(html).css(selector)
    elsif selector.is_a? Nokogiri::XML::NodeSet
      classes_for selector.first
    else
      selector.attributes.find{ |k, v| k == 'class' }.last.value
    end
  end

  def pause(seconds)
    sleep seconds * (Env.test_sleep_multiple || 1).to_i
  end

  def recursive_wait_for(selector:, limit: 10)
    if Nokogiri.parse(html).css(selector).present?
      true
    elsif limit <= 0
      raise "Couldn't find #{selector}"
    else
      sleep 0.2
      wait_for(selector: selector, limit: limit - 0.2)
    end
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
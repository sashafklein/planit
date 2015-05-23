class UserDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def bookmarklet_link
    content_tag :a, href: "#{ render 'bookmarklets/bookmarklet.js.erb', host: request.base_url, user: object }" do
      content_tag :span, class: 'planit-button neon' do
        "Planit"
      end
    end
  end
end
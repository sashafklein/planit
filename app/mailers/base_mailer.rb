class BaseMailer < ActionMailer::Base

  include Roadie::Rails::Mailer

  def self.hello
    "Planit <hello@plan.it>"
  end

  def self.admin
    "Planit Notification <admin@plan.it>"
  end

  def self.sent
    "Sent <sent@plan.it>"
  end

  def self.notifier
    "Notifier <notifier@plan.it>"
  end

  default from: hello

  layout 'layouts/mailer'

  private

  delegate :hello, :admin, :sent, :notifier, to: :class

  def include_inline_images(image_array=[])
    ['logo_name_only_white.png', 'logo_only_white.png'].concat(image_array).each do |image| 
      path_array = image.split('/')
      file = path_array.length == 1 ? File.read( image_path(image) ) : URI(image).read

      attachments.inline[ path_array.last ] = file
    end
  end

  def image_path(filename)
    "#{Rails.root}/app/assets/images/#{filename}"
  end
end
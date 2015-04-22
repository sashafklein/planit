class BaseMailer < ActionMailer::Base

  include Roadie::Rails::Mailer

  default from: "Planit <hello@plan.it>"

  layout 'layouts/mailer'

  def hello
    "Planit <hello@plan.it>"
  end

  def admin
    "Planit Notification <admin@plan.it>"
  end

  private

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
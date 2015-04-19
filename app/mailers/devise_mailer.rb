class DeviseMailer < Devise::Mailer

  helper :application
  include Devise::Controllers::UrlHelpers
  include Roadie::Rails::Mailer

  default from: "Planit <hello@plan.it>"

  layout 'layouts/mailer'

  def reset_password_instructions(record, token, opts = {})
    include_inline_images
    super(record, token, opts).deliver
  end

  private

  def devise_mail(record, action, opts={})
    initialize_from_record(record)
    roadie_mail headers_for(action, opts)
  end

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
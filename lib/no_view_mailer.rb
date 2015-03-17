module NoViewMailer

  require 'haml'

  def mail_no_layout(subject: '', content: '', overrides: {}, tag: 'p')
    defaults = {
      to: "Planit <hello@plan.it>",
      from: "Notifier <notifier@plan.if>",
    }

    options = defaults.merge(overrides).merge({ subject: subject })

    mail(options) do |format|
      encase_in_view stringify(content: content, tag: tag)
    end
  end

  private

  def stringify(content:, tag:)
    content.is_a?(Array) ? content.map{ |l| "<#{ tag }>#{ l }#</#{ tag }" }.join("") : content
  end

  def encase_in_view(content)
    path = File.join(Rails.root, 'app', 'views', 'layouts', 'mailer.html.haml')
    file = File.read(path).gsub('= yield', "INSERT_CONTENT_HERE")
    html = Haml::Engine.new(file).render
    html.gsub("INSERT_CONTENT_HERE", content)
  end
end
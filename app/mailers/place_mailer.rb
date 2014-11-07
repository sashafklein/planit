class PlaceMailer < ActionMailer::Base
  default from: "Notifier <notifier@plan.it>"

  def name_clash(location_id, diff)
    recipients = ['Sasha <sasha@plan.it>', 'Niko <niko@planit.it>' ]
    @location_id, @diff = location_id, diff

    recipients.each do |recipient|
      mail(to: recipient, subject: 'Item Clash')
    end
  end

  def merger(location_id, diff)
    recipients = ['Sasha <sasha@plan.it>', 'Niko <niko@planit.it>' ]
    @location_id, @diff = location_id, diff

    recipients.each do |recipient|
      mail(to: recipient, subject: 'Item Clash')
    end
  end

end

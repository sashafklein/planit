class PlaceMailer < ActionMailer::Base
  default from: "Notifier <notifier@plan.it>"

  def name_clash(location_id, diff)
    @location_id, @diff = location_id, diff

    recipients.each do |recipient|
      mail(to: recipient, subject: 'Item Clash')
    end
  end

  def merger(location_id, diff)
    @location_id, @diff = location_id, diff

    recipients.each do |recipient|
      mail(to: recipient, subject: 'Item Clash')
    end
  end

  def notify_of_bad_name_distance(name, distance, venue)
    @name, @distance, @venue_name = name, distance, venue_name
  end


  private

  def recipients
    ['Sasha <sasha@plan.it>', 'Niko <niko@plan.it>' ]
  end
end

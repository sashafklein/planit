class PlaceMailerPreview < ActionMailer::Preview
  def merger
    PlaceMailer.merger(1, { name: { object: 'Object Name', hash: 'Hash Name'}, street_address: { object: 'Object address', hash: 'Hash address'} })
  end

  def name_clash
    PlaceMailer.name_clash(1, { name: { object: 'Object Name', hash: 'Hash Name'}, street_address: { object: 'Object address', hash: 'Hash address'} })
  end
end
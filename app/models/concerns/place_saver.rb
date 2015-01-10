class PlaceSaver

  attr_accessor :place, :images
  delegate :uniqify_array_attrs, :array_attrs_unique?, to: :place
  def initialize(place, images=[])
    @place = place.persisted? ? place : Place.new(place.attributes)
    @images = images
  end

  def save!
    raise errors unless place.valid?
    do_saving(true)
  end

  def save
    return false unless place.valid?
    do_saving
  end

  private

  def do_saving(raise_errors=false)
    uniqify_array_attrs
    correct_and_deaccent_regional_info
    capitalize_categories
    format_hours
    save_and_validate_changes!(raise_errors)
  end

  def save_and_validate_changes!(raise_errors=false)
    return false unless validate_changes(raise_errors)
    @place.save!
    save_images!
    @place
  end

  def validate_changes(raise_errors=false)
    if !raise_errors 
      return ( array_attrs_unique? && regional_info_correct_and_deaccented? && categories_capitalized? && Services::TimeConverter.hours_converted?(place.hours) ) ? true : false 
    end

    raise "uniqify_array_attrs failed!" unless array_attrs_unique?
    raise "correct_and_deaccent_regional_info failed" unless regional_info_correct_and_deaccented?
    raise "capitalize_categories failed" unless categories_capitalized?
    raise "format_hours failed" unless Services::TimeConverter.hours_converted?(place.hours)
    true
  end

  def save_images!
    images.each do |photo|
      next if place.images.find_by(url: photo.url)
      photo.update_attributes!(imageable_type: place.class.to_s, imageable_id: place.id)
    end
  end

  def expand_country
    place.country = Directories::AnglicizedCountry.find(place.country) || place.country
    if expand_country?
      carmen_country = Carmen::Country.coded(place.country)
      place.country = carmen_country.name if carmen_country
    end
  end

  def expand_region
    if expand_region? && carmen_country = Carmen::Country.named(place.country)
      carmen_region = carmen_country.subregions.coded(place.region)
      place.region = carmen_region.name if carmen_region
    end
  end

  def correct_and_deaccent_regional_info
    place.country = place.country.no_accents if place.country_changed?
    place.region = place.region.no_accents if place.region_changed?
    place.subregion = place.subregion.no_accents if place.subregion_changed?
    place.locality = place.locality.no_accents if place.locality_changed?
    expand_country
    expand_region
  end

  def capitalize_categories
    place.categories = place.categories.map(&:titleize)
  end

  def expand_region?
    place.region_changed? && place.region && place.region.length < 3 
  end

  def expand_country?
    place.country_changed? && place.country && place.country.length < 3 
  end

  def should_update_country?
    place.country_changed? && place.country.length < 3
  end

  def regional_info_correct_and_deaccented?
    [:country, :region, :subregion, :locality].all? do |att|
      val = place.read_attribute(att)
      val.nil? || (!val.non_latinate? && val.length > 3)
    end
  end

  def categories_capitalized?
    place.categories.all?{ |c| c.capitalized? }
  end

  def format_hours
    place.add_to_hours Services::TimeConverter.convert_hours(place.hours)
  end

  def errors
    "Error(s) saving Place#{' #' + place.id.to_s if place.id}: #{place.errors.messages.map{ |m| m.last }.flatten.map{ |m| "'#{m}'" }.join(', ')}"
  end
end
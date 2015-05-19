class BaseValidator < ActiveModel::Validator

  attr_accessor :record
  def validate(record)
    @record = record
  end

  private

  def method_missing(m, *args, &block)
    return super unless m.to_s == self.class.to_s.underscore.split("_").first
    @record
  end

  def validate_presence!(*atts)
    atts.each do |att|
      if !record.send(att).is_defined?
        record.errors[:base] << "#{att.capitalize} can't be blank"
      end
    end
  end

  def validate_any!(*atts)
    atts.each do |att|
      if !record[att].compact.any?
        record.errors[:base] << "#{att.capitalize} can't be empty"
      end
    end
  end

  def validate_presence_of_one!(*options)
    unless options.any?{ |opt| record.send(opt).present? }
      record.errors[:base] << "Need one of the following: #{ options.join(', ') }" 
    end
  end

  def validate_enough!(threshold=1, *options)
    failures = []
    options.each do |opt|
      failures << opt if !record.send(opt).present?
    end
    unless (options.count - failures.count) >= threshold
      record.errors[:base] << "Needed at least #{threshold} of #{options.join(", ")} but was missing: #{ failures.join(', ') }" 
    end
  end

  def validate_group_uniqueness!(attributes, count_nil=false)
    attribute_hash = attributes.inject({}){ |hash, a| hash[a] = record[a]; hash}

    if count_nil
      return nil unless attribute_hash.compact.length == attribute_hash.length
    end

    if found = record.class.find_by(attribute_hash)
      record.errors[:base] << "A #{record.class} with that #{attributes.to_sentence} already exists. #{record.class.to_s.underscore}_id: #{found.id}, #{ attributes.map{ |k, v| k.to_s + ': ' + found[k].to_s }.join(', ') }" if found.id != record.id
    end
  end

end 
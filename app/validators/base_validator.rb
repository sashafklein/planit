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

end 
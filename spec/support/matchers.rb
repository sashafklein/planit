RSpec::Matchers.define :hash_eq do |expected_hash, expected_keys = []|
  match do |actual|
    dupl, expected_hash = [actual.dup, expected_hash].map(&:recursive_symbolize_keys)
    
    ( dupl.except( *(expected_keys.flatten) ) == expected_hash ) &&
      ( dupl.keys & expected_keys == expected_keys )
  end
end

RSpec::Matchers.define :array_eq do |expected|
  match do |actual|
    actual.sort == expected.sort
  end
end

RSpec::Matchers.define :float_eq do |expected, points_agreement = 3|
  match do |actual|
    actual.round(points_agreement) == expected.round(points_agreement)
  end

  failure_message do |actual|
    "expected that #{actual} would be equal to #{expected} within #{points_agreement} points of comparison"
  end
end
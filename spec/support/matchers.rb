RSpec::Matchers.define :hash_eq do |expected_hash, expected_keys = [], ignore_keys=[]|
  match do |actual|
    expected_keys.map!(&:to_sym)
    ignore_keys.map!(&:to_sym)
    dupl, expected_hash = [actual.dup, expected_hash].map(&:recursive_symbolize_keys).map(&:to_sh)

    ( dupl.except( *((expected_keys + ignore_keys).flatten) ) == expected_hash ) &&
      ( dupl.keys & expected_keys == expected_keys )
  end

  failure_message do |actual|
    actual = actual.recursive_symbolize_keys
    expected = expected_hash.recursive_symbolize_keys

    differences = {}
    actual.each{ |k, v| differences[k] = v if !expected[k] || expected[k] != v }
    differences = recursive_delete_differences(differences, actual, expected)

    "Expected equality:\n\n" + "#{actual.recursive_symbolize_keys.to_s}".colorize(:green) + "\n\n#{expected.recursive_symbolize_keys.to_s}\n\n" + "Differences:\n\n#{differences.to_s.colorize(:white)}".colorize(:white)
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

def recursive_delete_differences(diff, actual, expected)
  differences = diff.dup
  differences.each do |key, value|
    if value.is_a?(Hash)
      differences[key] = recursive_delete_differences(value, actual[key], expected[key])
    else
      differences.delete(key) if actual[key] == value && expected[key] == value
    end
  end
  differences
end
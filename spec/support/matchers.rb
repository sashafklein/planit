RSpec::Matchers.define :hash_eq do |expected_hash, opts = {}|
  match do |actual|
    dupl = actual.dup
    expected_hash = expected_hash.dup
    opts = { expected_keys: [], ignore_keys: [] }.to_sh.merge opts.to_sh

    dupl, expected_hash = [dupl, expected_hash].map(&:recursive_symbolize_keys).map(&:to_sh)
    
    if opts.ignore_nils
      dupl, expected_hash = [dupl, expected_hash].map(&:to_sh).map{ |e| e.deep_compact(allow_blank: opts.allow_blanks) }
    end

    if opts.expected_keys.any? || opts.ignore_keys.any?
      [opts.expected_keys, opts.ignore_keys].compact.each{ |a| a.map!(&:to_sym) }
      dupl, expected_hash = [dupl, expected_hash].map{ |e| e.except( *(opts.expected_keys + opts.ignore_keys).flatten ) }
    end

    ( dupl == expected_hash ) &&
      ( dupl.keys & opts.expected_keys == opts.expected_keys )
  end

  failure_message do |actual|
    actual = actual.recursive_symbolize_keys
    expected = expected_hash.recursive_symbolize_keys

    differences = {}
    actual.each{ |k, v| differences[k] = v if !expected[k] || expected[k] != v }
    differences = recursive_delete_differences(differences, actual, expected)

    "Got:\n\n".colorize(:blue) + 
      "#{actual.recursive_symbolize_keys.to_s}\n\n".colorize(:green) + 
      "Expected:\n\n".colorize(:blue) + 
      "#{expected.recursive_symbolize_keys.to_s}\n\n".colorize(:red) + 
      "Differences:\n\n".colorize(:blue) + 
      "#{differences}".colorize(:white)
  end
end

RSpec::Matchers.define :array_eq do |expected|
  match do |actual|
    actual.sort == expected.sort
  end

  failure_message do |actual|
    "Expected " + "#{actual}".colorize(:red) + " to eq " + "#{expected}".colorize(:green) + ".\n\nDifferences: " "#{(actual - expected)}".colorize(:blue)
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

RSpec::Matchers.define :render_or_redirect do |action, context|
  match do |actual| 
    actual.status >= 200 && actual.status <= 308
  end

  failure_message do |actual|
    "Action threw an error: #{action} - Context: #{context}"
  end
end

RSpec::Matchers.define :sorta_eq do |expected|
  match do |actual| 
    if actual.nil? || expected.nil?
      actual.nil? && expected.nil?
    else 
      actual.downcase.no_accents.include?(expected.downcase.no_accents)
    end
  end

  failure_message do |actual|
    "Expected '#{actual}' to include '#{expected}' (case-insensitive)"
  end
end

RSpec::Matchers.define :class_eq do |expected, name|
  match do |actual| 
    actual.class == expected.class
  end

  failure_message do |actual|
    "Expected the two #{name} values -- '#{actual}' and '#{expected}' -- to share the same class"
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
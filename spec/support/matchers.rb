RSpec::Matchers.define :hash_eq do |expected|
  match do |actual|
    actual.recursive_symbolize_keys == expected.recursive_symbolize_keys
  end
end

RSpec::Matchers.define :array_eq do |expected|
  match do |actual|
    actual.sort == expected.sort
  end
end
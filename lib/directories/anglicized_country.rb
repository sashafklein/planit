module Directories
  class AnglicizedCountry < Directories::BaseDirectory
    def self.find(given)
      country = list.find{ |c| c[:common] == given || c[:official] == given || c[:common_native] == given || c[:official_native] == given }
      country ? country[:common] : nil
    end

    private

    def self.list
      return @list if @list
      array = JSON.parse( file('json') )
      @list = array.map(&:recursive_symbolize_keys)
    end
  end
end
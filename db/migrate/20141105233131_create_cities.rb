class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :country_code
      t.string :name

      t.timestamps
    end
    add_index :cities, :country_code

    f = File.read("lib/cities.txt")
    f.split("\n").in_groups_of(1000) do |line_group|
      line_group.each do |line|
        @line = line
        if line
          split = line.split("\t")
          City.create!(country_code: split[0], name: split[1].gsub("\r", ''))
        end
      end
    end
  rescue
    binding.pry
    raise
  end
end

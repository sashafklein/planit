class Flag < BaseModel
  belongs_to :object, polymorphic: true

  json_accessor :info

  def self.print_states
    where(name: 'State').order('created_at ASC').map(&:print)
  end

  def print
    "\n#{id}: #{name} -- #{details}\n-------------------------"
    ap info
    puts "\n" 
  end

  def description
    [name, details].compact.join(" - ")
  end
end

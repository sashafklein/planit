class Flag < BaseModel
  belongs_to :object, polymorphic: true

  json_accessor :info

  default_scope { order('created_at ASC') }
  scope :states, -> { where(name: 'State').order('created_at ASC') }

  def self.print_states
    states.each(&:print)
    nil
  end

  def print
    puts "\n#{id}: #{name} -- #{details}\n-------------------------"
    ap info
    puts "\n" 
  end

  def description
    [name, details].compact.join(" - ")
  end
end

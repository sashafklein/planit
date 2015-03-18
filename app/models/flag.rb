class Flag < BaseModel
  
  is_polymorphic should_validate: false
  json_accessor :info

  default_scope { order('created_at ASC') }
  scope :named, -> (name) { where(name: name) }
  scope :states, -> { named('State') }

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

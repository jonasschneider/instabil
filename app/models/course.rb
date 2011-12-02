class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  belongs_to :page
  
  def group
    return nil if name.nil?
    num, subject = $1, $2 if name.match(/^(\d+)([^\d]+)\d+/)
    t = num.to_i == 4 ? 'vierstündig' : 'zweistündig'
    "#{subject.capitalize} (#{t})"
  end
end
class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  belongs_to :page
  
  def fach
    return nil if name.nil?
    $2.capitalize if name.match(/^(\d+)([^\d]+)\d+/)
  end
  
  def num
    return nil if name.nil?
    $1.to_i if name.match(/^(\d+)([^\d]+)\d+/)
  end
end
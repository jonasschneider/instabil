class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  belongs_to :page
end
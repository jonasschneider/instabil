class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
end
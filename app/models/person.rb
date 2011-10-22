class Person
  include Mongoid::Document
  
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  
  key :uid
  
  validates_presence_of :uid
  validates_presence_of :name
  
  embeds_one :page
end
class Page
  include Mongoid::Document
  
  field :kurs, type: Integer
  field :g8, type: Boolean
  
  field :lks, type: String
  field :bio, type: String
  #field :foto, type: String
  
  field :text, type: String
  field :text_by, type: String
  
  field :tags, type: Array
  
  embedded_in :person
end
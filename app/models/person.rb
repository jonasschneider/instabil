class Person
  include Mongoid::Document
  
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  
  key :uid
  
  validates_presence_of :uid
  validates_presence_of :name
  
  references_one :page, validate: false
  attr_protected :uid
  
  def api_attributes
    {}.tap do |att|
      fields.keys.each do |field|
        next if field[0] == '_'
        att[field] = read_attribute(field)
      end
      att['page'] = (page || build_page).api_attributes
    end
  end
end
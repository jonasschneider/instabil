class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  default_scope order_by(:name)
  
  field :name
  validates_presence_of :name
  validates_uniqueness_of :name
  
  belongs_to :page
  
  REGEX = /^(\d+)([^\d]+)\d\d$/
  
  def fach
    return nil if name.nil?
    
    return Instabil::SUBJECT_MAP[$2.downcase] if name.match(REGEX)
    'Sonstiges'
  end
  
  def num
    return nil if name.nil?
    $1.to_i if name.match(REGEX)
  end
  
  def api_attributes
    {
      "fach" => self.fach,
      "num" => self.num,
      "name" => self.name,
      
      "lehrer" => "XX",
      
      "foto" => "http://image.shutterstock.com/display_pic_with_logo/195/195,1159450466,2/stock-vector-group-of-people-vector-1914678.jpg",
      
      "text" => (page && page.text) || "",
      "author" => (page && page.author.name) || ""
    }
  end
end
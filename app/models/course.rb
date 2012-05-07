class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  default_scope order_by(:name)
  
  field :subject
  field :teacher
  field :weekday, type: Fixnum
  field :num, type: Fixnum

  validates_presence_of :subject, :teacher, :weekday, :num, :creator

  belongs_to :creator, class_name: 'Person', inverse_of: nil
  belongs_to :page

  embeds_many :tags, class_name: 'CourseTag'

  def weekday_name
    Instabil::WEEKDAYS[self.weekday]
  end

  def subject_name
    Instabil::SUBJECT_MAP[self.subject]
  end

  def name
    "#{subject_name} #{num == 4 ? 'vier' : 'zwei'}stündig bei #{teacher}, #{num == 4 ? 'Doppelstunde am' : 'erste Stunde in der Woche am'} #{weekday_name}"
  end
  
  def api_attributes
    {
      "id" => self.id,
      "fach" => Instabil::SUBJECT_MAP[self.subject],
      "weekday" => weekday_name,
      "num" => self.num,
      "lehrer" => self.teacher,
      
      "foto" => "http://image.shutterstock.com/display_pic_with_logo/195/195,1159450466,2/stock-vector-group-of-people-vector-1914678.jpg",
      
      "tags" => self.tags.map{|t|[t.name, t.id.to_s]},

      "text" => (page && page.text) || "",
      "author" => (page && (page.author_name.empty? ? page.responsible.name : page.author_name)) || ""
    }
  end
end
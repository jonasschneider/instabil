class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  CAP = 20
  scope :newest, order_by(:created_at, :desc).limit(CAP)
  
  field :body, type: String
  validates_length_of :body, minimum: 2, maximum: 150
  
  belongs_to :author, class_name: 'Person', inverse_of: nil
  validates_presence_of :author
  
  def client_attributes
    { author: author.name, created_at: created_at.strftime('%d.%m. %H:%M'), body: CGI.escapeHTML(body.gsub('\\', '')) }
  end
end
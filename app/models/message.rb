class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :body, type: String
  
  belongs_to :author, class_name: 'Person', inverse_of: nil
  validates_presence_of :author
  
  def client_attributes
    { author: author.name, created_at: created_at.strftime('%H:%M'), body: body }
  end
end
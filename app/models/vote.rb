class Vote
  include Mongoid::Document
  
  embedded_in :poll
  
  field :answer_id, type: BSON::ObjectId
  
  def answer
    return nil unless self.answer_id
    poll.answers.find(self.answer_id)
  end
  
  def answer=(answer)
    self.answer_id = answer.id
  end
  
  belongs_to :creator, class_name: 'Person', inverse_of: nil
  validates_presence_of :creator
end
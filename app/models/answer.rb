class Answer
  include Mongoid::Document
  
  field :name, type: String
  
  embedded_in :poll
  
  def vote_count
    poll.votes.select{|v| v.answer == self }.length
  end
  
  belongs_to :creator, class_name: 'Person', inverse_of: nil
  validates_presence_of :creator
end
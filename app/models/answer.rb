class Answer
  include Mongoid::Document
  
  field :name, type: String
  validates_uniqueness_of :name
  
  embedded_in :poll
  
  def vote_count
    poll.votes.select{|v| v.answer == self }.length
  end
  
  validate :must_be_poll_creator, :if => lambda { |a| !!a.poll && a.poll.serious }
  
  def must_be_poll_creator
    errors.add(:base, "You are not authorized") unless creator == poll.creator
  end
      
  belongs_to :creator, class_name: 'Person', inverse_of: nil
  validates_presence_of :creator
end
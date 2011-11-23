class Poll
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  validates_presence_of :title
  
  embeds_many :answers
  embeds_many :votes
  
  field :serious, type: Boolean, default: false
  field :end_date, type: Date
  
  belongs_to :creator, class_name: 'Person', inverse_of: nil
  validates_presence_of :creator
  
  def cast_vote!(user, answer)
    if serious
      raise "The end date has been reached" if Date.today > end_date
    end
    vote = vote_for(user)
    if serious
      raise "You already voted" unless vote.new_record?
    end
    vote.answer = answer
    vote.save!
  end
  
  def vote_for(user)
    votes.find_or_initialize_by(creator_id: user.id)
  end
end
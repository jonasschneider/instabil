class Poll
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  embeds_many :answers
  embeds_many :votes
  
  belongs_to :creator, class_name: 'Person', inverse_of: nil
  validates_presence_of :creator
  
  def cast_vote!(user, answer)
    vote = vote_for(user)
    vote.answer = answer
    vote.save!
  end
  
  def vote_for(user)
    votes.find_or_initialize_by(creator_id: user.id)
  end
end
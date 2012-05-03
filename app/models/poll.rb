class Poll
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  validates_presence_of :title
  
  embeds_many :answers
  embeds_many :votes
  
  field :serious, type: Boolean, default: false
  field :approval, type: Boolean, default: false
  field :end_date, type: Date
  validates_presence_of :end_date, :if => lambda { |p| p.serious }
  
  belongs_to :creator, class_name: 'Person', inverse_of: nil
  validates_presence_of :creator
  
  def cast_vote!(user, answer)
    if serious
      raise "The end date has been reached" if Date.today > end_date
    end

    if approval
      vote = votes.find_or_initialize_by(creator_id: user.id, answer_id: answer.id)
      unless vote.new_record?
        vote.destroy
        return false
      end
    else
      vote = vote_for(user)
    end

    if serious
      raise "You already voted" unless vote.new_record?
    end
    vote.answer = answer
    vote.save!
  end
  
  def popularity
    votes.count + 3 * (answers.map{|a|a.creator}.uniq.count)
  end
  
  alias_method :raw_end_date=, :end_date=
  
  def end_date=(date) 
    return if date.kind_of?(String) && date.empty?
    date = date.split("/").tap{|x| x[0], x[1] = x[1], x[0] }.join("/") if date.kind_of? String
    self.raw_end_date = date
  end 
  
  def vote_for(user)
    votes.find_or_initialize_by(creator_id: user.id)
  end

  def voting_for?(person, answer)
    if approval
      votes.where(creator_id: person.uid, answer_id: answer.id).count > 0
    else
      vote_for(person).answer == answer
    end
  end
end
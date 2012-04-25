class CourseTag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :author, class_name: 'Person', inverse_of: nil
  validates_presence_of :author

  embedded_in :course

  def destroyable_by?(user)
    author == user or user.moderator?
  end
end
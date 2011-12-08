class Page
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Timestamps
  include Canable::Ables
  
  field :text, type: String
  
  belongs_to :author, class_name: 'Person', inverse_of: nil
  validates_presence_of :author
  
  has_one :person
  has_one :course
  
  def name
    person ? person.name : (course ? course.name : nil)
  end
  
  def viewable_by?(user)
    true
  end
  
  def creatable_by?(user)
    true
  end
  
  def updatable_by?(user)
    author == user
  end

  def destroyable_by?(user)
    updatable_by?(user)
  end
  
  def date
    updated_at || created_at
  end
  
  def get_version_attributes(num)
    if num == self.version
      self.attributes
    elsif num == 0
      {}
    else
      self.versions.detect{ |v| v.version == num }.attributes
    end
  end
  
  def compare(old_version, new_version = version)
    reject_fields = %w(_id created_at updated_at version author_id person_id versions)
    
    old_version = get_version_attributes(old_version)
    new_version = get_version_attributes(new_version)
    
    diff_array = new_version.to_hash.to_a - old_version.to_hash.to_a
    diff_array.delete_if {|f| reject_fields.include?(f.first) }
    Hash[diff_array]
  end
end
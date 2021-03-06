class Page
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Timestamps
  include Canable::Ables
  
  field :text, type: String, default: ''
  field :title, type: String, default: ''
  field :subtitle, type: String, default: ''
  field :author_name, type: String, default: ''
  
  belongs_to :author, class_name: 'Person', inverse_of: nil
  validates_presence_of :author
  
  has_one :person
  has_one :course

  belongs_to :signed_off_by, class_name: "Person"

  def responsible
    self.versions.sort_by{|v|v.updated_at}.first.try(:author) || self.author
  end

  def name
    person ? "Personenbericht für #{person.name}" : (course ? "Kursbericht für #{course.name}" : "<Seite>")
  end
  
  def viewable_by?(user)
    # Course pages are viewable by everyone,
    # Person pages only by the person responsible and moderators
    !person || responsible == user || user.moderator?
  end
  
  def creatable_by?(user)
    true
  end
  
  def updatable_by?(user)
    (responsible == user && signed_off_by.nil?) || user.moderator?
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

  def wordcount
    (text || "").scan(/\w+/).length
  end
end
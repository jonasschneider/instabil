class Page
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Timestamps
  
  field :kurs, type: Integer
  field :g8, type: Boolean
  
  field :lks, type: String
  field :bio, type: String
  #field :foto, type: String
  
  field :text, type: String
  
  field :tags, type: Array
  
  belongs_to :author, class_name: 'Person', inverse_of: nil
  validates_presence_of :author
  
  belongs_to :person
  
  def api_attributes
    {}.tap do |att|
      fields.keys.each do |field|
        next if field[0] == '_'
        if field.to_s == 'g8'
          att[field] = read_attribute(field) ? 1 : 0
        else
          att[field] = read_attribute(field)
        end
      end
      att['author'] = self.author && author.name
      att['foto'] = nil
    end
  end
  
  def date
    updated_at || created_at
  end
  
  def zug
    g8 ? 'G8' : 'G9'
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
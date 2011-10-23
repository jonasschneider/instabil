class Page
  include Mongoid::Document
  include Mongoid::Versioning
  
  field :kurs, type: Integer
  field :g8, type: Boolean
  
  field :lks, type: String
  field :bio, type: String
  #field :foto, type: String
  
  field :text, type: String
  field :text_by, type: String
  belongs_to :author, class_name: 'Person'
  
  field :tags, type: Array
  
  embedded_in :person
  
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
end
require 'dropbox_sdk'
require 'base64'

class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  include Canable::Cans
  
  class << self
    attr_accessor :moderator_uids
  end

  self.moderator_uids = %w(schneijo kramerlu zimmerno kraifra hoffmelo wegneral cussaceg kraussre)

  field :active, type: Boolean, default: true
  
  field :uid, type: String
  field :name, type: String
  field :original_name, type: String
  field :email, type: String
  
  field :kurs, type: Integer
  field :g8, type: Boolean
  
  field :lks, type: String
  field :zukunft, type: String
  field :nachabi, type: String
  field :lebenswichtig, type: String
  field :nachruf, type: String

  embeds_many :tags

  class << self
    def dropbox_session
      @dsession ||= DropboxSession.deserialize(Base64.decode64(ENV["DROPBOX_SESSION"]))
    end

    def dropbox_client
      @dclient ||= DropboxClient.new(dropbox_session, :dropbox)
    end
  end
  
  def tag_length
    tags.map{|t|t.name.length}.sum + 3 * tags.length
  end

  def meta_fields
    %w(lks zukunft nachabi lebenswichtig nachruf).map{|s| s.to_sym }
  end

  def meta_complete?
    meta_fields.all? { |f| v=self.send(f); !v.nil? && !v.empty? }
  end

  def avatar_body
    self.class.dropbox_client.get_file("/Lukas/abizeitung-linked/people/avatar_thumbs/#{id}.jpg")
  rescue DropboxError
    nil
  end

  def avatar_type
    'image/jpg'
  end
  
  def avatar_url
    "/people/#{id}/avatar"
  end
    
  field :tags, type: Array
  
  before_create :set_original_name
  
  key :uid
  
  validates_presence_of :uid
  validates_presence_of :name
  
  validates :email, :allow_nil => true, :uniqueness => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/i }
  
  belongs_to :page
  attr_protected :uid
  
  def api_attributes
    {
      "uid" => self.uid,
      "email" => self.email,
      "name" => self.name,
      
      "page" => {
        "kurs" => self.kurs,
        "g8" => (g8.nil? ? 2 : g8 ? 1 : 0),
        
        "lks" => self.lks,
        "zukunft" => self.zukunft,
        "nachabi" => self.nachabi,
        "lebenswichtig" => self.lebenswichtig,
        "nachruf" => self.nachruf,
        
        "title" => page.try(:title) || '',
        "subtitle" => page.try(:subtitle) || '',

        "text" => page.try(:text) || '',
        
        "author" => page ? (page.author_name.blank? ? page.author.name : page.author_name) : '',
        
        "tags" => tags.map{|t|[t.name, t.id.to_s]}
      }
    }
  end
  
  def zug
    g8.nil? ? 'G8/G9?' : g8 ? 'G8' : 'G9'
  end
  
  def create_page(*att)
    self.page = Page.create! *att
    self.save!
    self.page
  end
  
  def set_original_name
    self.original_name = name
  end

  def assigned_pages
    Page.all.select{|p| p.responsible == self}
  end

  def moderator?
    self.class.moderator_uids.include? uid
  end
end
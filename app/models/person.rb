require "mongoid_paperclip"
require "fog/external/storage"
require "bertrpc"
require 'fog/external/backend/bertrpc'

class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  
  STORAGE_BACKEND = (ENV["FOG_STORAGE_BACKEND"] || 'localhost:8000').split(':')
  
  def self.with_page # HACK
    all.select{|p| p.page.present? }
  end
  
  def self.without_page # HACK
    all.select{|p| p.page.nil? }
  end
  
  field :uid, type: String
  field :name, type: String
  field :original_name, type: String
  field :email, type: String
  
  field :kurs, type: Integer
  field :g8, type: Boolean
  
  field :lks, type: String
  field :bio, type: String
  
  has_mongoid_attached_file :avatar, :storage => :fog, :fog_credentials => { 
    :provider => 'external',
    :delegate   => Fog::External::Backend::Bertrpc.new(*STORAGE_BACKEND)
  }, :fog_directory => 'paperclip', 
    :path => ':attachment/:id/:style/:filename',

    :styles => {
      :medium => "300x300#",
      :thumb  => "50x50>" }
  
  validate do
    if avatar.present?
      errors.add :avatar, "Bitte nur JPEGS oder PNGS. Typ = #{avatar_content_type} oder #{avatar.content_type}" unless avatar_content_type =~ /jpe?g/ || avatar_content_type =~ /png/
    end
  end
  
  def avatar_url(style = :original)
    "/people/#{id}/avatar/#{style}"
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
        "g8" => self.g8 ? 1 : 0,
        
        "lks" => self.lks,
        "bio" => self.bio,
        "foto" => nil,
        
        "text" => (page || Page.new).text,
        "author" => (page && page.author.name) || '',
        
        "tags" => [ ]
      }
    }
  end
  
  def zug
    g8 ? 'G8' : 'G9'
  end
  
  def create_page(*att)
    self.page = Page.create! *att
    self.save!
    self.page
  end
  
  def set_original_name
    self.original_name = name
  end
end
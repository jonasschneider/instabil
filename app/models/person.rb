require "mongoid_paperclip"
require "fog/external/storage"
require "bertrpc"
require 'fog/external/backend/bertrpc'
require "tmpdir"

class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Canable::Cans
  
  class << self
    attr_accessor :moderator_uids
  end

  self.moderator_uids = %w(schneijo kramerlu zimmerno cussaceg)

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

  if ENV["FOG_STORAGE_BACKEND"]
    STORAGE_BACKEND = (ENV["FOG_STORAGE_BACKEND"] || 'localhost:8000').split(':')
    fog_opts = { 
      :provider => 'external',
      :delegate   => Fog::External::Backend::Bertrpc.new(*STORAGE_BACKEND)
    }
  else
    fog_opts = {
      :provider => 'local',
      :local_root => Dir.mktmpdir
    }
  end
  
  has_mongoid_attached_file :avatar, :storage => :fog, :fog_credentials => fog_opts, :fog_directory => 'paperclip', 
    :path => ':attachment/:id/:style/:filename',

    :styles => {
      :medium => "300x300#",
      :thumb  => "50x50>" }
  
  embeds_many :tags
      
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
        "g8" => (g8.nil? ? 2 : g8 ? 1 : 0),
        
        "lks" => self.lks,
        "zukunft" => self.zukunft,
        "nachabi" => self.nachabi,
        "lebenswichtig" => self.lebenswichtig,
        
        "foto" => self.avatar_url(:medium),
        "foto_mtime" => self.avatar.updated_at,
        
        "text" => (page || Page.new).text,
        "author" => (page && page.author.name) || '',
        
        "tags" => tags.map{|t|t.name}
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
    Page.where(:author_id => id)
  end

  def moderator?
    self.class.moderator_uids.include? uid
  end
end
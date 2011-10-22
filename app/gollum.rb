require 'cgi'
require 'sinatra'
require 'gollum'
require 'mustache/sinatra'

dir = File.dirname(File.expand_path(__FILE__))

require "#{dir}/views/layout"
require "#{dir}/views/editable"

require 'omniauth/strategies/fichteid'

require "#{dir}/../server/stub"

module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra
    
    use OmniAuth::Builder do
      use Rack::Session::Cookie
      
      provider :fichteid, :key => ENV['FICHTE_HMAC_SECRET'] || 'mypw'
      
      configure do |c|
        c.on_failure = Proc.new do |env|
          [400, { 'Content-Type'=> 'text/html'}, [env["omniauth.error.type"].inspect]]
        end
      end
    end

    set :gollum_path, File.join(File.dirname(File.expand_path(__FILE__)), '..', 'tmp', 'wikidata-stubbed')
    set :wiki_options, {}

    dir = File.dirname(File.expand_path(__FILE__))

    # We want to serve public assets for now

    set :root, dir
    set :static,    true

    set :mustache, {
      # Tell mustache where the Views constant lives
      :namespace => Precious,

      # Mustache templates live here
      :templates => "#{dir}/templates",

      # Tell mustache where the views are
      :views => "#{dir}/views"
    }
    
    def load_wiki!
      begin
        access = Gitcloud::GollumGitAccess.new 'wikidata', 'sokratesius.dyndns-free.com', 3501
        @wiki = Gollum::Wiki.new(access, settings.wiki_options)
      rescue Exception => e
        e.inspect
      end
    end
    
    def get_page(name, *args)
      @wiki.page CGI.unescape(name), *args
    end
    
    helpers do
      def current_user
        @current_user
      end
    end
    
    before do
      unless (@current_user = session[:user]) || request.path == '/auth/fichteid/callback'
        redirect "/auth/fichteid"
      end
      load_wiki!
    end

    configure :test do
      enable :logging, :raise_errors, :dump_errors
    end
    
    get '/test/:page' do
      get_page params[:page]
    end

    get '/' do
      show_page_or_file('Home')
    end

    get '/edit/*' do
      @name = params[:splat].first
      
      if page = get_page(@name)
        @page = page
        @content = page.raw_data
        mustache :edit
      else
        mustache :create
      end
    end
    
    get '/auth/fichteid/callback' do
      session[:user] = env['omniauth.auth'].info
      redirect '/'
    end

    post '/edit/*' do
      page = get_page(params[:splat].first)
      name = params[:rename] || page.name
      committer = Gollum::Committer.new(@wiki, commit_message)
      commit    = {:committer => committer}

      update_wiki_page(@wiki, page, params[:content], commit, name,
        params[:format])
      update_wiki_page(@wiki, page.footer,  params[:footer],  commit) if params[:footer]
      update_wiki_page(@wiki, page.sidebar, params[:sidebar], commit) if params[:sidebar]
      committer.commit

      redirect "/#{CGI.escape(Gollum::Page.cname(name))}"
    end

    post '/create' do
      name = params[:page]

      format = params[:format].intern

      begin
        @wiki.write_page(name, format, params[:content], commit_message)
        redirect "/#{CGI.escape(name)}"
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    post '/revert/:page/*' do
      @name = params[:page]
      @page = get_page(@name)
      shas  = params[:splat].first.split("/")
      sha1  = shas.shift
      sha2  = shas.shift

      if @wiki.revert_page(@page, sha1, sha2, commit_message)
        redirect "/#{CGI.escape(@name)}"
      else
        sha2, sha1 = sha1, "#{sha1}^" if !sha2
        @versions = [sha1, sha2]
        diffs     = @wiki.repo.diff(@versions.first, @versions.last, @page.path)
        @diff     = diffs.first
        @message  = "The patch does not apply."
        mustache :compare
      end
    end

    post '/preview' do
      @name     = "Preview"
      @page     = @wiki.preview_page(@name, params[:content], params[:format])
      @content  = @page.formatted_data
      @editable = false
      mustache :page
    end

    get '/history/:name' do
      @name     = params[:name]
      @page     = get_page(@name)
      @page_num = [params[:page].to_i, 1].max
      @versions = @page.versions :page => @page_num
      mustache :history
    end

    post '/compare/:name' do
      @versions = params[:versions] || []
      if @versions.size < 2
        redirect "/history/#{CGI.escape(params[:name])}"
      else
        redirect "/compare/%s/%s...%s" % [
          CGI.escape(params[:name]),
          @versions.last,
          @versions.first]
      end
    end

    get '/compare/:name/:version_list' do
      @name     = params[:name]
      @versions = params[:version_list].split(/\.{2,3}/)
      @page     = get_page(@name)
      diffs     = @wiki.repo.diff(@versions.first, @versions.last, @page.path)
      @diff     = diffs.first
      mustache :compare
    end

    get %r{^/(javascript|css|images)} do
      halt 404
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      name = params[:captures][0]
      if page = get_page(name, params[:captures][1])
        @page = page
        @name = name
        @content = page.formatted_data
        @editable = true
        mustache :page
      else
        halt 404
      end
    end

    get '/search' do
      @query = params[:q]
      @results = @wiki.search @query
      @name = @query
      mustache :search
    end

    get '/pages' do
      @results = @wiki.pages
      @ref = @wiki.ref
      mustache :pages
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    def show_page_or_file(name)
      puts "Showing #{name} from #{@wiki.inspect}"
      if page = get_page(name)
        puts "got it!"
        @page = page
        @name = name
        @content = page.formatted_data
        @editable = true
        mustache :page
      elsif file = @wiki.file(name)
        content_type file.mime_type
        file.raw_data
      else
        @name = name
        mustache :create
      end
    end

    def update_wiki_page(wiki, page, content, commit_message, name = nil, format = nil)
      return if !page ||  
        ((!content || page.raw_data == content) && page.format == format)
      name    ||= page.name
      format    = (format || page.format).to_sym
      content ||= page.raw_data
      wiki.update_page(page, name, format, content.to_s, commit_message)
    end

    def commit_message
      { :message => params[:message], :name => current_user.name }
    end
  end
end

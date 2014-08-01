(RUBY_VERSION > "1.9") ? Encoding.default_external = Encoding::UTF_8 : $KCODE = 'UTF8' 

require 'rubygems'
require 'yaml' 
require 'active_support/all'
begin
  require "ya2yaml"
  require "google_translate"
  require "hmac-sha1"       
  require "httparty"
rescue LoadError 
  TextMate.message("One of required gems is missing.\nPlease install following gems:\nsudo gem install ya2yaml google_translate hmac-sha1 httparty")
  TextMate.exit_discard
end

class String 
  def strip
    self.gsub(/\A\s*["']?|["']?\s*\z/,'') 
  end
end

class BundleConfig
  attr_reader :default_locale, :default_locale_file, :default_locale_content, :mygengo_api_key, :mygengo_private_key
  def initialize
    @config = YAML::load(File.open(ENV["TM_BUNDLE_SUPPORT"] + "/config/config.yml").read)
    
    @default_locale = @config['default_locale'] 
    @default_locale_file = File.join(ENV['TM_PROJECT_DIRECTORY'], @config['default_locale_file']) 
    begin
      File.open(@default_locale_file, 'w') { |f| f.write({@default_locale => {}}.ya2yaml) } unless File.exists?(@default_locale_file)  
    rescue 
      TextMate.message("Can't create #{@config['default_locale_file']}. Are you in RoR project?")
      TextMate.exit_discard 
      return
    end
    @default_locale_content = YAML::load(File.open(@default_locale_file).read)   
    setup_mygengo
  end

  def setup_mygengo
    if @config['mygengo']
      @mygengo_api_key = @config['mygengo']['api_key'].to_s.strip
      @mygengo_private_key = @config['mygengo']['private_key'].to_s.strip
    end
  end 
  
  def has_mygengo_keys?
    @mygengo_api_key.present? and @mygengo_private_key.present?
  end
  
  def setup_keys
    have_an_account = TextMate.message_yes_no_cancel('Do you have a MyGengo Account?')
    
    unless have_an_account
      `open "http://mygengo.com/a/e04cf"`
      TextMate.message("A browser window was opened for you to create an account.\nOnce you are finished setting up the account, click OK")
    end
    
    @config['mygengo'] ||= {}
    @config['mygengo']['api_key'] = TextMate.input('Enter your mygengo.com API KEY', '').to_s.strip
    @config['mygengo']['private_key'] = TextMate.input('Enter your mygengo.com PRIVATE KEY', '').to_s.strip
    
    File.open(ENV["TM_BUNDLE_SUPPORT"] + "/config/config.yml", 'w') { |f| f.write(@config.to_yaml) }
    
    setup_mygengo
  end
  
end

BUNDLE_CONFIG = BundleConfig.new
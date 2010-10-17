require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/gengo_lib/my_gengo"

class TranslateStrings
  def initialize
    
    @translate_to = TextMate.input('Please enter the locale you want to auto-translate to (existing strings will not be overwritten)', '').to_s.strip.downcase
    return unless @translate_to.present?
        
    @translate_via = TextMate.choose("Choose how you want to translate the default locale?", ['Google Translate', 'MyGengo - Standard', 'MyGengo - Pro', 'MyGengo - Ultra'])
    
    unless @translate_via.zero?
      # Use MyGengo. Ask for API_KEYS if we haven't set them up yet 
      unless BUNDLE_CONFIG.has_mygengo_keys?
        BUNDLE_CONFIG.setup_keys; return 
      end    
      # Confirm
      return unless TextMate.message_yes_no_cancel("Are you sure?  This will cost money.")
    end

    default_locale = BUNDLE_CONFIG.default_locale_content[BUNDLE_CONFIG.default_locale]
    to_file = File.join(ENV['TM_PROJECT_DIRECTORY'], "config/locales/#{@translate_to}.yml")
        
    # Try to load new locale file
    to_locale = YAML::load(File.open(to_file).read)[@translate_to] rescue {}
        
    process(default_locale, to_locale, @translate_to)
    # Save translated locale
    File.open(to_file, 'w') { |f| f.write({@translate_to => to_locale}.ya2yaml) } 
    # Open translated file
    TextMate.open to_file

  end
  
  # Do the actual translating, or setup the placeholder
  def translate_string(string, from_locale, to_locale)
    if @translate_via.to_i.zero?  
      # Initialize Google translate
      @google_translator ||= Google::Translator.new
      
      # Change {{token}} to __token__ so it won't be replaced
      tokened_value = string.to_s.strip.gsub(/\{\{([^\}]+)\}\}/, '__\1__')
      result = nil                       
      if tokened_value.present?
        result = @google_translator.translate(from_locale.to_sym, to_locale.to_sym, tokened_value) rescue nil    
      end
      return result.to_s.gsub(/__(.*?)__/, '{{\1}}')
    else
      # Via MyGengo
      if !defined?(@auto_approve)
        @auto_approve = TextMate.message_yes_no_cancel('Do you want MyGengo jobs to be auto-approved?')
      end
      
      mygengo = MyGengo.new(BUNDLE_CONFIG.mygengo_api_key, BUNDLE_CONFIG.mygengo_private_key)
            
      tier = case @translate_via
      when 1
        'standard'
      when 2
        'pro'
      when 3
        'ultra'
      else
        return string
      end
      
      # play around with different parameter values to see their effect
      job = {
          'slug' => string.gsub(/\{\{([^\}]+)\}\}/, '[[[\1]]]'),
          'body_src' => string,
          'lc_src' => from_locale,
          'lc_tgt' => to_locale,
          'tier' => tier,
          'auto_approve' => @auto_approve
      }


      # place the full list of parameters relevant to this call in an array
      data = {'job' => job }

      resp = mygengo.create_job(data)
      begin
        return "___WAITING_JOB:#{resp['response']['job']['job_id']}___"
      rescue
        TextMate.textbox("An error happened while translating, the following was returned", resp.inspect.gsub(/[\'\"\$]/, ''))
        return string
      end
    end
  end

  # Loop through the default locale and translate everything into the new locale
  # Skip if the translated version exists in the new locale
  def process(from_obj, to_obj, translate_to)
    if from_obj.is_a?(Hash)
      from_obj.each do |key,value|
        if value.is_a?(String) and to_obj[key].blank?                         
          to_obj[key] = translate_string(value, BUNDLE_CONFIG.default_locale, translate_to)
        else
          to_obj[key] ||= {}
          process(value, to_obj[key], translate_to)
        end
      end
    end
  end
end

TranslateStrings.new
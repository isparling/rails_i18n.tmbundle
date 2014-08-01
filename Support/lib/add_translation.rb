require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"

class AddTranslation
  def initialize 
    @selected_text = ENV['TM_SELECTED_TEXT'].to_s.strip
    @path_parts = ENV['TM_FILEPATH'].split('app/').last.split('/')
    @path_parts.last.gsub!(/_controller|_helper|\..*/,'') 
    @vars = []
    set_tokens
    print_output
  end
  
  # Ask the user for the token they want to use for this key
  def set_tokens                       
    @default_text = @selected_text.parameterize('_').split("_")[0..4].join("_")
    @token_key = TextMate.input("Text Key (will be #{@path_parts.join('.')}.{your key})", @default_text) if @selected_text.present?
    @token_key = @token_key.to_s.strip
    @token = "#{@path_parts.join('.')}.#{@token_key}" 
  end 
  
  def set_vars
    @selected_text = @selected_text.gsub(/#\{([^}]+)\}/) do |match|
      var_name = $1.parameterize('_')
      @vars << ":#{var_name} => #{$1}"
      "%{#{var_name}}" 
    end
  end  
  
  def print_output
    if @token_key.present?
      set_vars
      add_to_locale
      print (@vars.present? ? "t('#{@token}', #{@vars.join(', ')})" : "t('#{@token}')")
    else
      print(@selected_text ? ENV['TM_SELECTED_TEXT'] : ENV['TM_CURRENT_LINE'])
      TextMate.exit_discard   
    end
  end

  def add_to_locale    
    token_parts = @path_parts.unshift(BUNDLE_CONFIG.default_locale) + @token_key.split('.')

    default_locale_content = BUNDLE_CONFIG.default_locale_content

    # Pop the last key of the token
    final_key = token_parts.pop

    main_sections = default_locale_content
    last_section = main_sections
    last_part = nil

    # Loop through each part, see if its in the new locale and if not add it
    token_parts.each_with_index do |part,i|
      last_section[part] ||= {}
      last_part = part
      # Except on last set last_section to current one
      last_section = last_section[part] if (i < token_parts.size - 1) 
    end

    if last_section[last_part][final_key]
      TextMate.message("The token #{final_key} is already in use, please choose another")
      TextMate.exit_discard
      return
    else
      last_section[last_part][final_key] = @selected_text
    end

    # Dump into the english locale
    File.open(BUNDLE_CONFIG.default_locale_file, 'w') do |f|
      f.write(default_locale_content.ya2yaml)
    end 
  end
end

# Run
AddTranslation.new



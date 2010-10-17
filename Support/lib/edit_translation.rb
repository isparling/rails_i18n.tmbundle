require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"

class EditTranslation
  def initialize 
    @selected_key = ENV['TM_SELECTED_TEXT'].to_s.strip.split('.').compact
    edit_locale if @selected_key.present?
  end

  def edit_locale    
    token_parts = @selected_key.unshift(BUNDLE_CONFIG.default_locale).dup

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
    
    new_value = TextMate.input("The key (#{@selected_key.join('.')}) value is:", last_section[last_part][final_key])
    if new_value.present?
      last_section[last_part][final_key]  = new_value.strip
      # Dump into the english locale
      File.open(BUNDLE_CONFIG.default_locale_file, 'w') do |f|
        f.write(default_locale_content.ya2yaml)
      end
    end 
  end
end

# Run
EditTranslation.new



require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"

class CalculateCost
  def initialize
    # Loop through the current locale and count the number of words
    total_words = process(BUNDLE_CONFIG.default_locale_content)
    
    TextMate.textbox("Total words: #{total_words}", "Cost on Google Translate: \\$0\nCost on myGengo into one other language:\n\tStandard: \\$#{total_words * 0.05}\n\tPro: \\$#{total_words * 0.10}\n\tUltra: \\$#{total_words * 0.15}")
  end

  # Loops through the locale and counts the words
  def process(from_obj)
    words = 0
    if from_obj.is_a?(Hash)
      from_obj.each do |key,value|
        if value.is_a?(String)
          words += value.split(/\s+/).reject {|w| w.gsub(/\s+/, '') == '' }.size
        else
          words += process(value)
        end
      end
    end
  
    return words
  end
end

# Run
CalculateCost.new
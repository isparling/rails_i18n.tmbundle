# just to remind you of some useful environment variables
# see Help / Environment Variables for the full list
# echo File: "$TM_FILEPATH"
# echo Word: "$TM_CURRENT_WORD"
# echo Selection: "$TM_SELECTED_TEXT"

# print ENV['TM_' + 'SELECTED_TEXT'.to_s.upcase] + 'ok'

require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"
require 'rubygems'
require 'yaml'

class Hash
  # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
  #
  # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v|   # <-- here's my addition (the 'sort')
          map.add( k, v )
        end
      end
    end
  end
end

class AddTranslation
  def initialize
    @selected_text = ENV['TM_SELECTED_TEXT'] || ''
    @path = ENV['TM_FILEPATH']
    @line = ENV['TM_CURRENT_LINE']
    path_parts = @path.split(/\//)
    path_parts[-1] = path_parts.last.split('.').shift.gsub(/_controller|_helper/,'')
    @path_parts = []
    @path_parts.unshift(path_parts.pop) until path_parts.last == 'app'
    
    get_token_key
    
    # Print so the results are added back into textmate
    variables = []
    new_text = @selected_text.dup
    @selected_text.scan(/#\{(.*?)\}/).flatten.each do |variable|
      #variable.gsub!(/\s/, '_')
      #naive assumption
      new_text.gsub!(/#\{#{variable}\}/, "%{#{variable}}")
      variables << ":#{variable} => #{variable}"
    end
    @selected_text = new_text
    
    add_to_locale
    
    variable_str = (variables.size > 0) ? (', ' + variables.join(', ')) : ''
    
    print "t(:#{@token_key}#{variable_str})"
  end
  
  # Ask the user for the token they want to use for this key
  def get_token_key
    if @selected_text.empty?
      @default_text = ENV['TM_CURRENT_LINE'].strip
      @selected_text = ENV['TM_CURRENT_LINE']
      did_select_text = false
    else
      @default_text = @selected_text.downcase.gsub(" ","_").gsub(/\W/, "").split("_")[0..4].join("_")
      did_select_text = true
    end
    
    @token_key = TextMate.input("Text Key (will be #{@path_parts.join('.')}.{your key})", @default_text)

    if !@token_key
      print did_select_text ? @selected_text : ENV['TM_CURRENT_LINE']
      exit
    end
  end

  def add_to_locale    
    token_parts = @token_key.split('.')
    token_parts.unshift(@path_parts.pop) until @path_parts.empty?

    default_locale = YAML::load(File.open($default_locale_file).read)

    token_parts.unshift('en')

    # Pop the last key of the token
    final_key = token_parts.pop

    main_sections = default_locale
    last_section = main_sections
    last_part = nil

    # Loop through each part, see if its in the new locale and if not add it
    token_parts.each_with_index do |part,i|
      last_section[part] ||= {}
      last_part = part
      # Except on last set last_section to current one
      if i < token_parts.size - 1
        last_section = last_section[part]
      end
    end

    if last_section[last_part][final_key]
      TextMate.message("The token #{final_key} is already in use, please choose another")
      TextMate.exit_discard
      return
    else
      last_section[last_part][final_key] = "#{@selected_text}"
    end

    # Dump into the english locale
    File.open($default_locale_file, 'w') do |f|
      f.write(default_locale.to_yaml)
    end
  end
end

# Run
AddTranslation.new



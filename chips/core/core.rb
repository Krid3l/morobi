module Mrb_Core

# TODO: See if this boilerplate can be moved in a separate file and
#  retrieved by each loaded chip
# -=-=-=- BOILERPLATE TO COPY FOR EACH NEW CHIP -=-=-=- #
extend Discordrb::EventContainer
extend Discordrb::Commands::CommandContainer

def self.chip_name
    @chip_name = File.basename(__FILE__, ".rb")
end

require "dead_end"
require_relative "#{chip_name}_text"
require_relative "../../text_fetch"
require_relative "../../lang"

# -=-=- Module vars -=-=- #
# direct reference to this chip's text module
def self.text_module
    @@text_module ||= Module.const_get("Mrb_" + Unicode::capitalize(chip_name) + "_Text")
end

def self.text_module_path
    @@text_module_path ||= File.dirname(__FILE__) + "/" + chip_name + "_text.rb"
end

# -=-=- </module vars> -=-=- #

# -=-=- Module methods -=-=- #
# I'm sure we can get rid of this by moving it in text_fetch.rb...
def self.getTextFromKey(key, vals = [])
    return Mrb_TextFetcher.getText(key, text_module, text_module_path, vals)
end
# -=-=- </module methods> -=-=- #
# -=-=-=- </boilerplate> -=-=-=- #

command :randomNumber do |event, min, max|
    rand(min.to_i .. max.to_i)
end

command:slocCount do |event|
    sloc_count = 0
    for ruby_file in Dir["./**/*.rb"]
        sloc_count += File.foreach(ruby_file).inject(0) {|c, line| c+1}
    end
    getTextFromKey("SLOC_COUNT", [sloc_count])
end

command:changeLanguage do |event, lang_name|
    if lang_name == nil
        return "You did not give me any language name to work with."
    elsif $loaded_langs.has_key?(lang_name.upcase)
        $current_lang = lang_name
        return(
            getTextFromKey("LANGUAGE_CHANGE_OK")
        )
    else
        return(
            "Hm. The language name \"#{lang_name}\" that you gave me is not "\
            "present in the ISO 639 standard, nor is it one of the custom "\
            "languages defined in my config.\n"\
            "For the list of languages that ISO 639 indexes, check this out: "\
            "<https://www.loc.gov/standards/iso639-2/php/code_list.php>\n"\
            "There's also the \"customLanguages\" command if you want to see "\
            "the list of custom babble flavors I can spurt out."
        )
    end
end

# TODO: Move response string to text_fetch.rb and translate it
command:loadedLanguages do |event|
    str_loaded_langs = ""
    $loaded_langs.each do |lang_name_all_caps, lang_data|
        str_loaded_langs += "#{lang_name_all_caps.capitalize};"
    end
    return "The following languages are loaded:\n#{str_loaded_langs}"
end

command:customLanguages do |event|
    custom_langs = []
    ($loaded_langs).each do |lang_name_all_caps, lang_data|
        if lang_data["IS_CONLANG"]
            custom_langs.push[lang_name_all_caps]
        end
    end
    if custom_langs.empty?
        return getTextFromKey("NO_CUSTOM_LANGUAGE_DEFINED")
    else
        stringed_custom_langs = ""
        custom_langs_count = custom_langs.size
        custom_langs.each do |custom_lang_name_all_caps|
            stringed_custom_langs += custom_lang_name_all_caps.capitalize
            if custom_langs_count > 1
                stringed_custom_langs += ", "
            end
            custom_langs_count -= 1
        end
        return getTextFromKey("CUSTOM_LANGUAGES", [stringed_custom_langs])
    end
end

command:repo do |event|
    return getTextFromKey("SOURCE_CODE_LINK", ["https://github.com/Krid3l/morobi"])
end

command:info do |event|
    "```\n" +
    " __  __                 _     _\n" +
    "|  \\/  |               | |   (_)\n" +
    "| \\  / | ___  _ __ ___ | |__  _ \n" +
    "| |\\/| |/ _ \\| '__/ _ \\| '_ \\| |\n" +
    "| |  | | (_) | | | (_) | |_) | |\n" +
    "|_|  |_|\\___/|_|  \\___/|_.__/|_|\n" +
    "--------------------------------\n" +
    "Mоҳобӣ - Μοροβι - Մորոբի - モロビ\n" +
    "--------------------------------\n" +
    "A modular and decentralized bot.\n\n" +
    "Version: Pre-Release 0.0.1\n" +
    "Author:  Kridel#0017\n" +
    "Tech:    Ruby 3 + discordrb\n" +
    "License: GPLv2\n" +
    "```"
end
    
end
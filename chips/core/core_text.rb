##
# Contains the core chip's response strings loaded from the sibling .json file.
#
# This should be used as a template for any new chip's _text file.
# Apart from the module name and lang_list, there's nothing to change.
module Mrb_Core_Text

##
# List of languages in which response strings can be fetched from this text
# module. These are looked-up and validated by the +lang+ module.
#
# If you are working on a translation in the .json file, Morobi won't mind if
# one of lang_list's languages are not in @text. So you can input the new
# language's name whenever you want.
def self.lang_list
    @lang_list ||= [
        "english",
        "french"
    ]
end

# -=-=-=- DON'T CHANGE ANYTHING BELOW unless you're modifying Morobi -=-=-=- #

##
# To allow for insertion of values inside Morobi's response strings, use a
# substring $_VALx, where x is replaced by the insertion order of the expected
# value, e.g.: $_VAL1, $_VAL2, $_VAL3, and so on (start with 1, not with 0).
#
# Upon recieving a piece of text with one or several instances of $_VALx in
# it, text_fetch.rb will replace every occurrence with the value(s)
# transmitted to its self.getText method.
def self.text
    @text ||= loadText()
end

def self.loadText
    require "json"

    chip_name = File.basename(__FILE__).sub("_text.rb", "")
    json_file = File.read("chips/#{chip_name}/#{chip_name}_text.json")
    loaded_text = JSON.parse(json_file)
    lang_list.each do |lang_name|
        unless loaded_text.key?(lang_name)
            puts (
                "[ERROR] Language \"#{lang_name}\" is defined in "\
                "#{chip_name}_text.rb's language list, but is not in the "\
                "translations provided by the companion .json file.\nExiting..."
            )
            exit
        end
    end

    return loaded_text
end

end
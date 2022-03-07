module Mrb_Core_Text

def self.lang_list
    @lang_list ||= {
        "eng" => "english",
        "fra" => "français",
    }
end

# to allow for insertion of values inside Morobi's response strings, insert
#  the substring $_VALx, where x is replaced by the position of this $_VAL
#  occurrence, e.g.: $_VAL1, $_VAL2, $_VAL3, and so on
#  start with 1, not with 0
# upon recieving a piece of text with one or several instances of $_VALx in
#  it, text_fetch.rb will replace every occurrence with the value(s)
#  transmitted to its self.getText method
def self.text
    @text ||= {
        "eng" => {
            "MODULE_OK" => "Core module correctly loaded.",
            "SLOC_COUNT" => "I currently consist of $_VAL1 lines of Ruby code.",
            "LANGUAGE_CHANGE_OK" => "I'll be speaking English from now on.",
            "SOURCE_CODE_LINK" => "The repository of my source code is here:\n$_VAL1"
        },
        "fra" => {
            "MODULE_OK" => "Module principal correctement chargé.",
            "SLOC_COUNT" => "Je consiste actuellement de $_VAL1 lignes de code en Ruby.",
            "LANGUAGE_CHANGE_OK" => "Je parlerai désormais en français.\n"\
                "(Si les textes de mes puces additionnelles ont été traduits.)",
            "SOURCE_CODE_LINK" => "Le dépôt de mon code source est ici:\n$_VAL1"
        }
    }
end

end
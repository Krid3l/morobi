module Mrb_Core_Text

def self.lang_list
    @lang_list ||= [
        "english",
        "french"
    ]
end

# to allow for insertion of values inside Morobi's response strings, use a
#  substring $_VALx, where x is replaced by the insertion order of the expected
#  value, e.g.: $_VAL1, $_VAL2, $_VAL3, and so on
#  start with 1, not with 0
# upon recieving a piece of text with one or several instances of $_VALx in
#  it, text_fetch.rb will replace every occurrence with the value(s)
#  transmitted to its self.getText method
def self.text
    @text ||= {
        "english" => {
            "MODULE_OK" => "Core module correctly loaded.",
            "SLOC_COUNT" => "I currently consist of $_VAL1 lines of Ruby code.",
            "LANGUAGE_CHANGE_OK" => "I'll be speaking English from now on.",
            "SOURCE_CODE_LINK" => "The repository of my source code is here:\n$_VAL1",
            "CUSTOM_LANGUAGES" => "My host has defined the following custom language(s):\n$_VAL1",
            "NO_CUSTOM_LANGUAGE_DEFINED" => "My host has not defined any custom language(s) yet."
        },
        "french" => {
            "MODULE_OK" => "Module principal correctement chargé.",
            "SLOC_COUNT" => "Je consiste actuellement de $_VAL1 lignes de code en Ruby.",
            "LANGUAGE_CHANGE_OK" => "Je parlerai désormais en français.\n"\
                "(Si les textes de mes puces additionnelles ont été traduits.)",
            "SOURCE_CODE_LINK" => "Le dépôt de mon code source est ici:\n$_VAL1",
            "CUSTOM_LANGUAGES" => "Mon hôte a défini la/les langue(s) personnalisées suivantes:\n$_VAL1",
            "NO_CUSTOM_LANGUAGE_DEFINED" => "Mon hôte n'a pas encore défini de langue(s) personnalisée(s)."
        }
    }
end

end
module Mrb_Lang

require_relative "config"
require "iso-639"

MRB_CONFIG = Mrb_Config.config

$default_lang = MRB_CONFIG["DEFAULT_LANGUAGE"].downcase
$current_lang = ""
$loaded_langs = {}

def self.loadLang(lang_name)
    if $loaded_langs.has_key?(lang_name.upcase)
        puts "[INFO] Language \"#{lang_name}\" already loaded."
    else
        lang_to_add = getLangByName(lang_name)
        if lang_to_add == "NOT_A_VALID_LANGUAGE"
            puts (
                "[ERROR] Tried to load a non-valid language: \"#{lang_name}\" "\
                "is not defined in the ISO 639 standard or in config.rb's "\
                "custom languages list."\
                "Exiting..."
            )
            exit
        else
            $loaded_langs.merge!({lang_name.upcase => lang_to_add})
        end
    end
end

def self.loadDefaultLang
    if $default_lang == ""
        puts "[ERROR] No language code specified in config.rb.\n"\
            "Exiting..."
        exit
    else
        loadLang($default_lang)
    end
end

# TODO: write a getLangByCode too and apply it to morobi.rb's checks
def self.getLangByName(lang_name)
    iso_639_lookup = ISO_639.find_by_english_name(lang_name.capitalize)
    # is that language code / name found in the ISO 639 referential?
    if iso_639_lookup.empty?
        # is it defined in the custom languages list of config.rb?
        if MRB_CONFIG["CUSTOM_LANGUAGES"].has_key?(lang_name)
            return {
                "LANG_INFO" => MRB_CONFIG["CUSTOM_LANGUAGES"][lang_name],
                "IS_CONLANG" => true
            }
        else
            puts(
                "[WARNING] The language \"#{lang}\" is not a valid ISO 639 "\
                "language or conlang code.\n"\
            )
            return "NOT_A_VALID_LANGUAGE"
        end
    else
        return {
            "LANG_INFO" => iso_639_lookup,
            "IS_CONLANG" => false
        }
    end
end

end
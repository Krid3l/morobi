require "discordrb"
require "unicode"

require_relative "config"

MRB_CONFIG = Mrb_Config.config

morobi = (
    Discordrb::Commands::CommandBot.new token: MRB_CONFIG["TOKEN"],
    client_id: MRB_CONFIG["CLIENT_ID"],
    prefix: MRB_CONFIG["COMMAND_PREFIX"]
)

# TODO: put the bot info in another file so that config.rb can be removed from
#  the .gitignore
=begin
since config.rb is in the .gitignore, create your own from this template:

module Mrb_Config

def self.config
    @config ||= {
        "TOKEN" => <insert bot token as string here>,
        "CLIENT_ID" => <insert client ID as integer here>,
        "COMMAND_PREFIX" => "$_",
        # expects an ISO 639-3 code, a.k.a. three-letter language code
        # reference here: https://iso639-3.sil.org/code_tables/639/data
        # NOTE FOR CONSTRUCTED LANGUAGE CREATORS:
        # if you are translating / have translated one or several chips in a
        #  constructed language, Morobi will let it slide if you input the
        #  following language code: "cl?", where the question mark is replaced
        #  by a single digit (that way there can be up to 10 conlangs per chip)
        "DEFAULT_LANGUAGE" => "eng",
        # chips are Morobi's modules -- the core chip is automatically loaded
        #  specify the other chips you want to load on Morobi's startup below
        "CHIPS" => [
        ]
    }
end

end
=end
default_lang = MRB_CONFIG["DEFAULT_LANGUAGE"].downcase

chip_list = MRB_CONFIG["CHIPS"]
chip_list.unshift("core")

for chip in MRB_CONFIG["CHIPS"] do
    require_relative "chips/" + chip + "/" + chip
    require_relative "chips/" + chip + "/" + chip + "_text"

    chip_module = Module.const_get("Mrb_" + Unicode::capitalize(chip))
    chip_text_module = Module.const_get("Mrb_" + Unicode::capitalize(chip) + "_Text")

    # -=-=-=- LANGUAGE-RELATED CHECKS -=-=-=- #

    chip_has_english_text = true

    if default_lang == ""
        puts "[ERROR] No language code specified in config.rb.\n"\
            "Exiting..."
        exit
    end

    # is it constructed like an ISO 639-3 code?
    unless default_lang.match(/^[a-z]{3}$/)
        # is it constructed like a conlang code? (see config.rb)
        if default_lang.match(/^cl[0-9]{1}$/)
            puts "[INFO] Constructed language code specified in config.rb."
        else
            puts(
                "[ERROR] The language code \"#{default_lang}\" specified in "\
                "config.rb is not a valid ISO 639-3 or conlang code.\n"\
                ">>> See: https://iso639-3.sil.org/code_tables/639/data"
            )
            exit
        end  
    end

    unless chip_text_module.lang_list.has_key?("eng")
        if chip == "core"
            puts(
                "[WTF?] The core chip does not list English in its language list.\n"\
                ">>> It seems that the core chip's texts have been tampered with.\n"\
                "Please check the contents of chips/core/core_text.rb "\
                "or download a fresh instance of Morobi.\n"\
                "Exiting..."
            )
            exit
        else
            puts(
                "[WARNING] #{chip}_text.rb's does not list English in its language list.\n"\
                ">>> Morobi uses English as fallback when the default language specified "\
                "in config.rb is missing, exercise caution."
            )
            chip_has_english_text = false
        end
    end

    if chip_text_module.lang_list.has_key?(default_lang)
        chip_module.setLang(default_lang)
    else
        puts(
            "[INFO] The \"#{chip}\" chip does not list the code "\
            "\"#{default_lang}\" in its #{chip}_text.rb's language list."
        )
        if chip_has_english_text
            chip_module.setLang("eng")
        else
            puts (
                "[ERROR] Tried to fallback to English text, but the \"#{chip}\" chip has none.\n"\
                "Exiting..."
            )
            exit
        end
    end

    chip_text_module.lang_list.each do |lang_code, lang_name|
        # people working on the translation of a chip's text should not be
        #  bothered with errors on startup; a translator can include any lang
        #  code as a key in the chip's text hash, even if the same lang code is
        #  not in the lang_list - however the opposite case should be prevented
        unless chip_text_module.text.has_key?(lang_code)
            puts(
                "[ERROR] Language \"#{lang_name}\" has not been defined in "\
                "#{chip}_text.rb's \"text\" hash, but is in the chip's lang_list.\n"\
                "Exiting..."
            )
            exit
        end
    end

    # -=-=-=- </language checks> -=-=-=- #

    morobi.include! chip_module
end

morobi.run
require "discordrb"
require "unicode"

require_relative "config"
require_relative "lang"

MRB_CONFIG = Mrb_Config.config

morobi = (
    Discordrb::Commands::CommandBot.new token: MRB_CONFIG["TOKEN"],
    client_id: MRB_CONFIG["CLIENT_ID"],
    prefix: MRB_CONFIG["COMMAND_PREFIX"]
)

default_lang = MRB_CONFIG["DEFAULT_LANGUAGE"].downcase

chip_list = MRB_CONFIG["CHIPS"]
# ensures that the core chip is loaded first
chip_list.unshift("core")

Mrb_Lang.loadDefaultLang()

for chip in MRB_CONFIG["CHIPS"] do
    require_relative "chips/" + chip + "/" + chip
    require_relative "chips/" + chip + "/" + chip + "_text"

    chip_module = Module.const_get("Mrb_" + Unicode::capitalize(chip))
    chip_text_module = Module.const_get("Mrb_" + Unicode::capitalize(chip) + "_Text")

    # -=-=-=- CHIP-LEVEL LANGUAGE-RELATED CHECKS -=-=-=- #

    chip_has_english_text = true

    unless chip_text_module.lang_list.include?("english")
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

    chip_text_module.lang_list.each do |lang_name|
        # people working on the translation of a chip's text should not be
        #  bothered with errors on startup; a translator can include any lang
        #  code as a key in the chip's text hash, even if the same lang code is
        #  not in the lang_list - however the opposite case should be prevented
        unless chip_text_module.text.has_key?(lang_name)
            puts(
                "[ERROR] Language \"#{lang_name}\" has not been defined in "\
                "#{chip}_text.rb's \"text\" hash, but is in the chip's lang_list.\n"\
                "Exiting..."
            )
            exit
        end
        # TODO: english is loaded twice when processing the core chip, fix this
        Mrb_Lang.loadLang(lang_name)
    end

    # -=-=-=- </chip-level language checks> -=-=-=- #

    morobi.include! chip_module
end

morobi.run
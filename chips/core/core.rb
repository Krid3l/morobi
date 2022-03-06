module Mrb_Core

    # TODO: See if this boilerplate can be moved in a separate file and
    #  retrieved by each loaded chip
    # -=-=-=- BOILERPLATE TO COPY FOR EACH NEW CHIP -=-=-=- #
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    def self.chip_name
        @chip_name = File.basename(__FILE__, ".rb")
    end

    require_relative "#{chip_name}_text"
    require_relative "../../text_fetch"

    # -=-=- Module vars -=-=- #
    # direct reference to this chip's text module
    def self.text_module
        @text_module ||= Module.const_get("Mrb_" + Unicode::capitalize(chip_name) + "_Text")
    end

    def self.text_module_path
        @text_module_path ||= File.dirname(__FILE__) + "/" + chip_name + "_text.rb"
    end

    # lang.rb will try to retrieve text in this language from the chip's text module
    def self.current_lang
        @@current_lang
    end
    # -=-=- </module vars> -=-=- #

    # -=-=- Module methods -=-=- #
    def self.setLang(lang_code)
        @@current_lang = lang_code
    end

    def self.getTextFromKey(key, vals = [])
        return Mrb_TextFetcher.getText(key, text_module, text_module_path, current_lang, vals)
    end
    # -=-=- </module methods> -=-=- #
    # -=-=-=- </boilerplate> -=-=-=- #
  
    command :helloCore do |event|
        getTextFromKey("MODULE_OK")
    end

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

    command:changeLanguage do |event, lang_code|
        # TODO: This is a quasi-dupe of some code present in morobi.rb
        #  it'd be good to convert this into a method for the core chip
        if lang_code == nil
            return "You did not give me any language code to work with."
        # is the provided lang_code constructed like an ISO 639-3 code
        #  or one of Morobi's conlang codes?
        elsif lang_code.match(/^[a-z]{3}$/) || lang_code.match(/^cl[0-9]{1}$/)
            setLang(lang_code)
            return getTextFromKey("LANGUAGE_CHANGE_OK")
        else
            return(
                "Hm. The language code \"#{default_lang}\" that you gave me is "\
                "not a valid ISO 639-3 nor one of my constructed language codes.\n"\
                "Check this out: https://iso639-3.sil.org/code_tables/639/data"
            )
        end
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
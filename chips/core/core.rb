module Mrb_Core

# -=-=- Copy this when creating a new chip -=-=- #
chip_name = File.basename(__FILE__).sub(".rb", "")

require_relative "../common"
require_relative "#{chip_name}_text"

common = Mrb_Chip_Common.new(chip_name, Module.const_get("Mrb_#{chip_name.capitalize}_Text"))

extend Discordrb::EventContainer
extend Discordrb::Commands::CommandContainer

# -=-=- < /chip boilerplate > -=-=- #

command :randomNumber do |event, min, max, how_many|
    random_numbers = []
    # iteration on the array does not work?... classic loop inbound!
    iter = how_many.to_i
    until iter <= 0
        random_numbers.push(rand(min.to_i .. max.to_i))
        iter -= 1
    end
    return random_numbers.to_s
end

# returns number of lines in all of Morobi's .rb files
# TODO: make the command ignore Ruby comments in a not-too-bloated way
command :slocCount do |event|
    sloc_count = 0
    for ruby_file in Dir["./**/*.rb"]
        sloc_count += File.foreach(ruby_file).inject(0) {|c, line| c+1}
    end
    common.getTextFromKey("SLOC_COUNT", [sloc_count])
end

# will set the current language (stored in lang.rb) if the provided lang name
#  is valid (as per lang.rb's checks)
command :changeLanguage do |event, lang_name|
    puts $loaded_langs
    if lang_name == nil
        return "You did not give me any language name to work with."
    elsif $loaded_langs.has_key?(lang_name.upcase)
        $current_lang = lang_name
        return(
            common.getTextFromKey("LANGUAGE_CHANGE_OK")
        )
    else
        return(
            "Hm. The language name \"#{lang_name}\" that you gave me is not "\
            "present in the ISO 639 standard, nor is it one of the custom "\
            "languages defined in my config.\n"\
            "I'm expecting the full language name in English as the "\
            "parameter for this command. (e.g.: french, russian, igbo...) \n"\
            "For the list of languages that ISO 639 indexes, check this out: "\
            "<https://www.loc.gov/standards/iso639-2/php/code_list.php>\n"\
            "There's also the \"customLanguages\" command if you want to see "\
            "the list of custom babble flavors I can spurt out."
        )
    end
end

# TODO: Move response string to text_fetch.rb and translate it
command :loadedLanguages do |event|
    str_loaded_langs = ""
    $loaded_langs.each do |lang_name_all_caps, lang_data|
        str_loaded_langs += "#{lang_name_all_caps.capitalize};"
    end
    return "The following languages are loaded:\n#{str_loaded_langs}"
end

# lists custom languages defined in config.rb
command :customLanguages do |event|
    custom_langs = []
    ($loaded_langs).each do |lang_name_all_caps, lang_data|
        if lang_data["IS_CONLANG"]
            custom_langs.push[lang_name_all_caps]
        end
    end
    if custom_langs.empty?
        return common.getTextFromKey("NO_CUSTOM_LANGUAGE_DEFINED")
    else
        stringed_custom_langs = ""
        custom_langs_count = custom_langs.size
        custom_langs.each do |custom_lang_name_all_caps|
            stringed_custom_langs += custom_lang_name_all_caps.capitalize
            # do not add a comma + space if last custom lang in the list
            if custom_langs_count > 1
                stringed_custom_langs += ", "
            end
            custom_langs_count -= 1
        end
        return common.getTextFromKey("CUSTOM_LANGUAGES", [stringed_custom_langs])
    end
end

command :repo do |event|
    return common.getTextFromKey("SOURCE_CODE_LINK", ["https://github.com/Krid3l/morobi"])
end

# TODO: add an option in config.rb to "blacklist" commands so they're not
#  visible when using :help, e.g. if you want to test your new command in peace
#  without users from your server using it
# also, restrict the dir scanning to the chips folder?
# plus, it'd be good to have command descriptions directly in the code, perhaps
#  via RDoc?
command :help do |event|
    # key = command name, value = array of arguments to give to that command
    command_list = {}
    # TODO: only parses the main chip file, check for multiple files in chip
    for chip in $chip_list do
        command_list.merge!(
            chip => {}
        )
        for line in IO.readlines("chips/#{chip}/#{chip}.rb")
            if line.start_with?("command")   
                command_name = (line.split)[1].sub(":", "")
                command_args = (line[/\|(.*?)\|/m, 1])
                for event_variation in ["event, ", "event,", "event"]
                    command_args = command_args.gsub(event_variation, "")
                end
                command_list[chip].merge!({command_name => command_args})
            end
        end
    end
    # compose response
    response = common.getTextFromKey("HELP", [$command_prefix]) + "\n```\n"
    ptr = 0
    command_list.each_key do |chip_name|
        ptr += 1
        response += "#{chip_name.capitalize} chip\n-=-=-=-=-\n"
        command_list[chip_name].each do |cmd_name_key, cmd_args_value|
            response += "#{cmd_name_key}"
            unless cmd_args_value == ""
                response += " (#{cmd_args_value})"
            end
            response += "\n"
        end
        if ptr < command_list.size()
            response += "\n"
        end
    end
    response += "```"
    return response
end

command :info do |event|
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
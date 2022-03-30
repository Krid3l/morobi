##
# The Game Dictionary chip provides Morobi with a simple system to store a
# repertoire of games for your Discord server.
#
# All entries must be stored in +gamedict_entries.json+.
#
# Example uses:
# - Allowing users to quickly see which games are usually played by the server
#   members without relying on a dedicated channel with a long list of games
# - Transmitting the precompiled games list from this module to other Morobi
#   chips related to gaming
module Mrb_Gamedict

# -=-=- Copy this when creating a new chip -=-=- #
chip_name = File.basename(__FILE__).sub(".rb", "")

require_relative "../common"
require_relative "#{chip_name}_text"

text_module_ref = Module.const_get("Mrb_#{chip_name.capitalize}_Text")

# instance of common.rb, a.k.a. Morobi's chips' common toolbox.
common = Mrb_Chip_Common.new(chip_name, text_module_ref)

extend Discordrb::EventContainer
extend Discordrb::Commands::CommandContainer
# -=-=- < /chip boilerplate > -=-=- #

def self.entries_file
    @entries_file ||= "gamedict_entries.json"
end

# -=-=- Checks running after the chip has been loaded -=-=- #

entries_file_path = "#{File.dirname(__FILE__)}/#{entries_file}"
if !(File.file?(entries_file_path))
    File.new(entries_file_path, "w")
end

# -=-=- < /post-load checks > -=-=- #

##
# Discord command.
#
# Confirms if the present module is loaded or not.
command :isGameDictLoaded do |event|
    return "Game dictionary loaded."
end

end
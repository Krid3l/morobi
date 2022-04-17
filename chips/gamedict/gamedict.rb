##
# The Game Dictionary chip provides Morobi with a simple system to store a
# repertoire of games for your Discord server.
#
# Example uses:
# - Allowing users to quickly see which games are usually played by the server
#   members without relying on a dedicated channel with a long list of games
# - Transmitting the precompiled games list from this module to other Morobi
#   chips related to gaming
#
# This chip must have a +gamedict_entries.json+ to work ; it will create an
# empty one if no existing instance is found. All entries must be stored in
# this file.
#
# Each top-level entry in gamedict_entries.json is a category.
# Each second-level entry is a single game.
#
# Example :
#  "Category name": {
#      "Name of first game": {
#          "aliases": ["other accepted spellings of the game's name"],
#          "icon": "optional - insert hyperlink to an image file here",
#          "year": 2022,
#          "platforms": ["insert platforms on which the game runs as three-letter codes, see convert_platform_codes() for the list of codes"],
#          "performance": how powerful of a computer to run this game? 1: toaster, 2: decent PC, 3: recent gaming PC,
#          "tags": ["all these tags will be displayed as a list when the game card is displayed"]
#      }
#      "Name of second game": {
#          "and so on..."
#      }
#  }
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

require "json"
require "open-uri"

def self.entries_file
    @entries_file ||= "gamedict_entries.json"
end

entries_hash = {}
game_categories = []
game_cards = {}

# -=-=- Checks running after the chip has been loaded -=-=- #

entries_file_path = "#{File.dirname(__FILE__)}/#{entries_file}"
if !(File.file?(entries_file_path))
    File.new(entries_file_path, "w")
end

def self.is_blank(obj)
    if obj.strip.empty? || obj == false || obj == [] || obj == {}
        return true
    else
        return false
    end
end

def self.convert_platform_codes(platforms_array, game_name)
    platforms_string = ""
    ptr = 0
    platforms_array.each do |platform_code|
        ptr += 1
        case platform_code
        when "WIN"
            platforms_string += "Microsoft Windows"
        when "MAC"
            platforms_string += "MacOS"
        when "LIN"
            platforms_string += "Linux"
        when "AMG"
            platforms_string += "AmigaOS"
        when "HAK"
            platforms_string += "Haiku"
        when "BSD"
            platforms_string += "BSD"
        when "SRN"
            platforms_string += "SerenityOS"
        else
            puts "[ERROR] OS code #{platform_code} in #{game_name}'s entry is invalid.\nExiting..."
            exit
        end
        unless ptr >= platforms_array.length
            platforms_string += ", "
        end
    end

    return platforms_string
end

def self.validate_and_format_entry(game_name, game_info, category)
    if is_blank(game_name)
        puts "[ERROR] One of the game names in #{entries_file} is blank.\nExiting..."
        exit
    end

    if game_info == {}
        puts "[ERROR] Info for game #{game_name} in #{entries_file} is blank.\nExiting..."
        exit
    end

    game_icon = game_info["icon"]

    if is_blank(game_icon)
        game_icon = "https://kridel.me/missing.png"
    else
        url_ext = File.extname(game_icon)
        unless [".jpg", ".jpeg", ".gif", ".png", ".webp"].include?(url_ext)
            puts "[ERROR] The image link for game #{game_name} in #{entries_file} "\
                "has the extension #{url_ext}. It's not an image file.\nExiting..."
            exit
        end
    end

    formatted_entry = {
        game_name => {
            "ALIASES" => game_info["aliases"],
            "ICON" => game_icon,
            "YEAR" => game_info["year"],
            "PLATFORMS" => convert_platform_codes(game_info["platforms"], game_name),
            "PERFORMANCE_INDEX" => game_info["performance"],
            "TAGS" => game_info["tags"],
            "CATEGORY" => category
        }
    }

    return formatted_entry
end

entries_hash = JSON.parse!(File.read(entries_file_path))
entries_hash.each do |category, cat_contents|
    game_categories.push(category)
    cat_contents.each do |game_name, game_info|
        formatted_entry = validate_and_format_entry(game_name, game_info, category)
        game_cards.merge!(formatted_entry)
    end
end

# -=-=- < /post-load checks > -=-=- #

##
# Discord command.
#
# Displays an information card about a given game.
#
# TODO: Add more comments.
command :gameCard do |event, *game_name|
    if game_name == nil || game_name.empty?
        return common.getTextFromKey("NO_GAME_NAME_GIVEN")
    end

    str_game_name = ""
    name_ptr = 0
    game_name.each do |game_name_word|
        name_ptr += 1
        str_game_name += game_name_word
        unless name_ptr >= game_name.length
            str_game_name += " "
        end
    end

    alias_found_for = ""
    game_cards.each do |card_game_name, card_game_info|
        game_name_aliases = card_game_info["ALIASES"]
        unless game_name_aliases == nil || game_name_aliases.empty?
            if game_name_aliases.include?(str_game_name.downcase)
                alias_found_for = card_game_name
            end
        end
    end

    if alias_found_for != ""
        str_game_name = alias_found_for
    end

    unless game_cards.key?(str_game_name)
        return common.getTextFromKey("GAME_DOES_NOT_EXIST", [str_game_name])
    end

    game_info = game_cards[str_game_name]
    event.channel.send_embed do |embed|
        embed.title = "#{str_game_name}"
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: game_info["ICON"])
    end

    case game_info["PERFORMANCE_INDEX"]
    when 1
        perf_string = common.getTextFromKey("PC_TOASTER")
    when 2
        perf_string = common.getTextFromKey("PC_CAPABLE")
    when 3
        perf_string = common.getTextFromKey("PC_WARMACHINE")
    else
        perf_string = "hmmm. compute."
    end

    tags_string = ""
    tag_ptr = 0
    game_info["TAGS"].each do |tag|
        tag_ptr += 1
        tags_string += tag
        unless tag_ptr >= game_info["TAGS"].length
            tags_string += ", "
        end
    end

    return "**#{common.getTextFromKey("GAME_CATEGORY")}**: #{game_info["CATEGORY"].capitalize}\n"\
        "**#{common.getTextFromKey("GAME_YEAR_OUT")}**: #{game_info["YEAR"]}\n"\
        "**#{common.getTextFromKey("GAME_PLATFORMS")}**: #{game_info["PLATFORMS"]}\n"\
        "**#{common.getTextFromKey("GAME_PERFORMANCE")}**: #{perf_string}\n"\
        "**#{common.getTextFromKey("GAME_TAGS")}**: #{tags_string}\n"\
end

command :listGames do |event|
    response = "**#{common.getTextFromKey("GAME_LIST")}**\n\n"

    entries_hash.each do |category, cat_contents|
        cat_title_list = []
        response += "__#{category.capitalize}__\n"
        cat_contents.each do |game_name, game_info|
            cat_title_list.push(game_name)
        end

        ptr = 0
        cat_title_list.sort.each do |game_name|
            ptr += 1
            response += "*#{game_name}*"
            if ptr >= cat_title_list.length
                response += "\n\n"
            else
                response += ", "
            end
        end
    end

    return response
end

end
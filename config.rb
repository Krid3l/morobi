##
# Morobi's configuration file.
module Mrb_Config

# put your bot's credentials in a file named creds.rb inside a Ruby module
# here's the template:
#
#   module Mrb_Creds
#
#   def self.creds
#       @creds ||= { 
#           "TOKEN" => "your bot's token here, with the quotes",
#           "CLIENT_ID" => your bot's client id here, without quotes,
#           "ADMIN_ROLE" => "the name of your server's admin role, with quotes"
#       }
#   end
#
#   end
#

require_relative "creds"

MRB_CREDS = Mrb_Creds.creds

def self.config
    @config ||= {
        "TOKEN" => MRB_CREDS["TOKEN"],
        "CLIENT_ID" => MRB_CREDS["CLIENT_ID"],
        "ADMIN_ROLE" => MRB_CREDS["ADMIN_ROLE"],
        "COMMAND_PREFIX" => "$_",
        # expects the name of a language in english, or the name of a conlang
        # Morobi will try to fetch strings in this language when responding to
        #  Discord users
        "DEFAULT_LANGUAGE" => "english",
        # chips are Morobi's modules -- the core chip is automatically loaded
        #  specify the other chips you want to load on Morobi's startup below
        "CHIPS" => [
            "gamedict"
        ],
        # if you are translating / have translated one or several chips in a
        #  constructed language - or if the language is not specified in the
        #  ISO 639 standard - you can define that language in the hash below
        # the hashes are constructed like entry objects from the iso-639 gem
        #  to simplify the language module and rely on a unified checkup method
        # >>> see: https://github.com/xwmx/iso-639
        #  (#alpha3_bibliographic is omitted since alpha3 is its alias)
        # example entry:
        #   "LANGUAGE_NAME_IN_CAPS" => {
        #       "alpha3" => "3-letter lang code (english name)",
        #       "alpha3_terminologic" => "3-letter lang code (native name)",
        #       "alpha2" => "2-letter lang code",
        #       "english_name" => "the full native name of the custom lang",
        #       "french_name" => "can be a dupe of english_name if you want"
        #   }
        "CUSTOM_LANGUAGES" => {
        }
    }
end

end
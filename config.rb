module Mrb_Config

# put your bot's credentials in a file named creds.rb inside a Ruby module:
#   module Mrb_Creds
#
#   def self.creds
#       @creds ||= { 
#           "TOKEN" => "your bot's token here, with the quotes",
#           "CLIENT_ID" => your bot's client id here, without quotes
#       }
#   end
#
#   end

require_relative "creds"

MRB_CREDS = Mrb_Creds.creds

def self.config
    @config ||= {
        "TOKEN" => MRB_CREDS["TOKEN"],
        "CLIENT_ID" => MRB_CREDS["CLIENT_ID"],
        "COMMAND_PREFIX" => "$_",
        # expects an ISO 639-3 code, a.k.a. three-letter language code
        # reference here: https://iso639-3.sil.org/code_tables/639/data
        # NOTE FOR CONSTRUCTED LANGUAGE CREATORS:
        # if you are translating / have translated one or several chips in a
        #  constructed language, Morobi will let it slide if you input the
        #  following language code: "cl?", where the question mark is replaced
        #  by a single digit (that way there can be up to 10 conlangs per chip)
        "DEFAULT_LANGUAGE" => "fra",
        # chips are Morobi's modules -- the core chip is automatically loaded
        #  specify the other chips you want to load on Morobi's startup below
        "CHIPS" => [
        ]
    }
end

end
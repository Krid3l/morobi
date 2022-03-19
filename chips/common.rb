##
# Common toolbox for all of Morobi's chips.
#
# Chips are Morobi's modules. They can be loaded independently by putting their
# name in the appropriate +config+ subhash.
#
# Maybe I should allow chips to require other chips for their init.
class Mrb_Chip_Common

##
# +name+ is the name of the chip being loaded.
#
# +text_mod+ is a reference to the chip's text module fetched via +const_get+.
def initialize(name = "", text_mod = "")
    @chip_name = name
    @text_module_ref = text_mod
    if @chip_name == ""
        puts("[ERROR] No chip name provided to Chip constructor.\nExiting...")
        exit
    end
    if @text_module_ref == ""
        puts("[ERROR] No text module reference provided to Chip constructor.\nExiting...")
        exit
    end

    require_relative "../lang"
    require_relative "../text_fetch"
    require_relative "#{@chip_name}/#{@chip_name}_text"

    # -=-=- Module vars -=-=- #

    ##
    # String. Contains the path to the chip's text module.
    def text_module_path
        @text_module_path ||= "#{@chip_name}/#{@chip_name}_text.rb"
    end

    # -=-=- </module vars> -=-=- #

    # -=-=- Module methods -=-=- #

    ##
    # Helper that packs everything the text fetcher needs before querying a string.
    def getTextFromKey(key = "", vals = [])
        return Mrb_TextFetcher.getText(key, @text_module_ref, vals)
    end

    # -=-=- </module methods> -=-=- #
end # initialize

end # class
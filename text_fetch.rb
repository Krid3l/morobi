module Mrb_TextFetcher

def self.getText(key, text_module, text_module_path, current_lang, vals = [])
    require_relative text_module_path
    text_to_return = text_module.text[current_lang][key]

    if text_to_return == ""
        return "Sorry, I could not fetch the queried string #{key} with language code #{current_lang}."
    end

    # -=-=-=- VALUE-INSERTION STEP -=-=-=- #
    if vals.kind_of?(Array)
        # in how many places a value is to be put inside the fetched string?
        slots_in_text = text_to_return.scan("$_VAL").size
        if slots_in_text > 0
            # is the size of the vals array coherent with the number of
            #  substring insertions to be performed?
            if vals.length() >= slots_in_text
                for val_id in 0..(slots_in_text - 1)
                    stringed_val = vals[val_id].to_s
                    stringed_slot = "$_VAL" + (val_id + 1).to_s
                    # sub() does not seem to work here for some reason
                    #  I'm gon hafta be less suave here, please forgive me
                    text_to_return[stringed_slot] = stringed_val
                end
            else
                puts "[ERROR] The vals array given to Mrb_TextFetcher.getText has less "\
                    "elements than the number of value slots in the #{key} string.\n"\
                    "Exiting..."
                exit
            end
        elsif slots_in_text <= 0 && vals.length() > 0
            puts "[ERROR] The vals array given to Mrb_TextFetcher.getText has elements "\
                "in it but the string with id #{key} has zero value slots.\n"\
                "Exiting..."
            exit
        end
    else
        puts "[ERROR] The fifth argument given to Mrb_TextFetcher.getText while "\
            "attempting to fetch the string with id #{key} is not an array.\n"\
            "Exiting..."
        exit
    end
    # -=-=-=- </value insertion> -=-=-=- #

    return text_to_return
end

end
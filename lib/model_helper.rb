########################################################################################################################
# Utiltity functions for models.
#
# @author Christopher Lee.
########################################################################################################################
module ModelHelper

  ######################################################################################################################
  # Converts all all array values to single string values
  ######################################################################################################################
  def ModelHelper.flatten_map input_map
    input_map.each do |key, value|
      if value && value.kind_of?(Array)
        input_map[key] = value[0]
      end
    end
    input_map
  end

end
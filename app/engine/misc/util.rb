module Util

  def Util.get_public_uploaded_file file_name
    File.read(Rails.root.join('public', 'uploads', file_name))
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Parses nexpose ISO 8601 formated time.
  # Can return null.
  #
  #---------------------------------------------------------------------------------------------------------------------
  def Util.parse_utc_time(iso_8601_time)
    # We only go as granular as minutes
    if iso_8601_time =~ /(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})/
      year = $1.to_i
      month = $2.to_i
      day = $3.to_i
      hour = $4.to_i
      min = $5.to_i

      time = Time.utc year, month, day, hour, min
      return time
    end

    nil
  end

  #---------------------------------------------------------------------------------------------------------------------
  # For serialized data that contains arrays, use this to flatten to a string or convert to array.
  #
  # input  - The array or encoded string.
  # encode - true if the input is an array.
  #
  # returns An array or string dependent on input params, null on error.
  #---------------------------------------------------------------------------------------------------------------------
  def Util.process_db_input_array(input, encode=false)
    begin
      if encode
        encoded_string = ""
        input.each do |p|
          output = p.to_s
          output.squeeze!
          output.gsub!(/[\r\n\t]/, '\r' => '', '\n' => '', '\t' => '')
          output.chomp!
          unless output.empty?
            if encoded_string.length > 0
              encoded_string << "||"
            end
            encoded_string << output
          end
        end
        encoded_string
      else
        decoded_string = input.split("||")
        decoded_string
      end
    rescue Exception => e
      logger = LogManager.instance
      logger.add_log_message "[!] Error in processing DB input array: #{e.backtrace}"
      # Error situation return null
      return nil
    end
  end

end
module Util

  def Util.get_public_uploaded_file file_name
    File.read(Rails.root.join('public', 'uploads', file_name))
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Parses nexpose ISO 8601 formated time
  #---------------------------------------------------------------------------------------------------------------------
  def Util.parse_utc_time nexpose_iso_8601_time
    # We only go as granular as minutes
    if nexpose_iso_8601_time =~ /(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})/
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
end
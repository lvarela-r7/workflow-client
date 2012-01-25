module Util

  def Util.get_public_uploaded_file file_name
    File.read(Rails.root.join('public', 'uploads', file_name))
  end
end
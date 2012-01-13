#-----------------------------------------------------------------------------------------------------------------------
# Ensures proper application configuration before application launch
#-----------------------------------------------------------------------------------------------------------------------
begin

  # Ensure the uploads folder exists
  uploads_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../public/uploads'))
  if not (Dir.exist? (uploads_dir))
    Dir.mkdir uploads_dir
  end


end
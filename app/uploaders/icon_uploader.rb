class IconUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    'uploads/map'
  end

  def filename
    if original_filename
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension}"
    end
  end

end
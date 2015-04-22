module Directories
  class BaseDirectory

    def self.file(filetype, filename='store', class_name=self.to_s)
      File.read File.join( Rails.root, 'lib', 'directories', filetype, class_name.demodulize.underscore, "#{filename}.#{filetype}")
    end

    def file(filetype, filename='store')
      self.class.file(filetype, filename, self.class.to_s)
    end
  end
end
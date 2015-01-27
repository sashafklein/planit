meta_extensions = %w( Base HstoreAccessor ArrayAccessor)

meta_extensions.each do |ext|
  ActiveRecord::Base.send(:include, "MetaExt::#{ext}".constantize)
end
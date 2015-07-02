require 'core_extensions'
# Include monkey patch to active record invalidating model caches
ActiveRecord.include CoreExtensions::ActiveRecord


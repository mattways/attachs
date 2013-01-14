module RailsUploads
  module Schema
    
    def attachment(*args)
      column args[0], :string 
    end
   
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send :include, RailsUploads::Schema

module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Backends
      # Methods for DB backed attachments
      module DbFileBackend
        def self.included(base) #:nodoc:
          Object.const_set(:DbFile, Class.new(ActiveRecord::Base)) unless Object.const_defined?(:DbFile)
          base.belongs_to  :db_file, :class_name => '::DbFile', :foreign_key => 'db_file_id'
        end

        # Creates a temp file with the current db data.
        def create_temp_file
          write_to_temp_file current_data
        end
        
        # Gets the current data from the database
        def current_data
          db_file.data
        end
        
        protected
          # Destroys the file.  Called in the after_destroy callback
          def destroy_file
            db_file.destroy if db_file
          end
          
          # Saves the data to the DbFile model
          def save_to_storage
            if save_attachment?
              # NOTE there seems to be a problem with the PostgreSQL gem. Storing data manually on Create/Update.
              if self.connection.class == ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
                unless db_file
                  build_db_file
                  db_file.save!
                  self.class.update_all ['db_file_id = ?', self.db_file_id = db_file.id], ['id = ?', id]
                end
                # NOTE Use a slightly adjusted SQL call than Rails would use with ::bytea
                self.connection.update_sql "UPDATE \"db_files\" SET \"data\" = '#{ActiveRecord::ConnectionAdapters::PostgreSQLColumn.string_to_binary(temp_data)}'::bytea, \"updated_at\" = '#{Time.now.to_s(:db)}' WHERE \"id\" = #{self.db_file_id};"
              else
                (db_file || build_db_file).data = temp_data
                db_file.save!
                self.class.update_all ['db_file_id = ?', self.db_file_id = db_file.id], ['id = ?', id]
              end
            end
            true
          end
      end
    end
  end
end
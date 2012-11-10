class PrepareActiveRecord
  class << self
    def prepare_default_schema
      ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :model_ones do |t|
          t.integer :num
          t.timestamps
        end

        create_table :model_twos do |t|
          t.timestamps
        end
      end
    end

    def run_migration(relative, root)
      file = migration_file_name(relative, root)

      require(file)

      # I think this is horrendous but I don't want to hardcode the name of the class either.
      loaded_klass = Module.constants.last

      Object.const_get(loaded_klass).new.change
    end

    private

    def migration_file_name(relative, root)
      absolute = File.expand_path(relative, root)
      dirname, file_name = File.dirname(absolute), File.basename(absolute).sub(/\.rb$/, '')
      Dir.glob("#{dirname}/[0-9]*_*.rb").grep(/\d+_#{file_name}.rb$/).first
    end
  end
end

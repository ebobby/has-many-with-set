class PrepareActiveRecord
  class << self
    def prepare_default_schema
      ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

      ActiveRecord::Schema.define do
        self.verbose = false

        create_table :ones do |t|
          t.integer :num
          t.timestamps
        end

        create_table :twos do |t|
          t.timestamps
        end
      end
    end

    def run_migration(parent, child)
      generator = HasManyWithSet::MigrationGenerator.new([parent, child])
      generator.destination_root = Dir.tmpdir

      migration_path = generator.create_migration_file
      migration_file = File.join(Dir.tmpdir, migration_path)

      require(migration_file)

      CreateOnesTwosSet.new.change

      File.delete(migration_file)
    end
  end
end

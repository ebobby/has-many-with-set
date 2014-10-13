require "test_helper"

PARENT = "ModelOne"
CHILD  = "ModelTwo"
MIGRATION_PATH = "test/tmp/"
MIGRATION_FILE = "db/migrate/create_model_ones_model_twos_set"

PrepareActiveRecord.prepare_default_schema

class MigrationGeneratorTest < Rails::Generators::TestCase
  tests HasManyWithSet::MigrationGenerator

  destination MIGRATION_PATH
  setup :prepare_destination

  test "Generate migration" do
    run_generator [ PARENT, CHILD ]

    assert_migration MIGRATION_FILE
  end
end

PrepareActiveRecord.run_migration(MIGRATION_FILE, MIGRATION_PATH)

class HasManyWithSetTest < ActiveSupport::TestCase
  def setup
    unless @initialized
      # Migration test has to run first, I do not like that but is the only way to actually
      # test the whole thing.
      PrepareActiveRecord.prepare_default_schema
      PrepareActiveRecord.run_migration(MIGRATION_FILE, MIGRATION_PATH)
      @initialized = true
    end
  end

  test "parent class has the getter" do
    assert_respond_to ModelOne.new, "model_twos"
  end

  test "parent class has the setter" do
    assert_respond_to ModelOne.new, "model_twos="
  end

  test "child class has the getter" do
    assert_respond_to ModelTwo.new, "model_ones"
  end

  test "getter type" do
    assert_kind_of Array, ModelOne.new.model_twos
  end

  test "children can be saved" do
    15.times do
      assert ModelTwo.new.save
    end

    assert (ModelTwo.all.size == 15)
  end

  test "parent saved with empty set" do
    assert ModelOne.new(:num => 0).save
    assert ModelOne.last.model_twos.size == 0
  end

  test "parent saved with non-empty set" do
    record = ModelOne.new
    record.model_twos = ModelTwo.all
    record.num = record.model_twos.size
    assert record.save

    record = ModelOne.find(record.id)
    assert record.num == record.model_twos.size
  end

  test "parent saved with several children" do
    ModelTwo.all.each do |m|
      record = ModelOne.new(:num => 1)
      record.model_twos << m
      assert record.save

      record = ModelOne.find(record.id)
      assert record.num == record.model_twos.size
    end
  end

  test "set reuse" do
    items = ModelTwo.all

    25.times do
      master_record = ModelOne.new

      rand(items.size + 1).times do
        master_record.model_twos << items[rand(items.size)]
      end

      master_record.num = master_record.model_twos.size
      master_record.save

      master_items = master_record.model_twos

      set_id = master_record.send("model_ones_model_twos_set_id")

      100.times do
        record = ModelOne.new(:num => master_items.size)
        record.model_twos = master_items
        record.save

        assert(record.send("model_ones_model_twos_set_id") == set_id,
               "Set ids do not match #{ record.send('model_ones_model_twos_set_id') } == #{ set_id }")
      end
    end
  end

  test "do not save repeated items" do
    items = ModelTwo.all
    master_record = ModelOne.new(:num => items.size)

    master_record.model_twos = ModelTwo.all
    master_record.model_twos << items
    master_record.model_twos << items
    master_record.model_twos << items
    master_record.save

    assert master_record.model_twos.size == items.size
  end

  test "children can see parents" do
    item = ModelTwo.create

    how_many = rand(50)

    how_many.times do
      record = ModelOne.new(:num => 1)
      record.model_twos << item
      record.save
    end

    assert item.model_ones.size == how_many, "#{ item.model_ones.size } != #{ how_many }"
  end

  test "items count match" do
    ModelOne.all.each do |m|
      assert m.num == m.model_twos.size
    end
  end
end

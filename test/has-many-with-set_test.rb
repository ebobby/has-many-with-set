require "test_helper"

PARENT = "One"
CHILD  = "Two"
MIGRATION_PATH = "test/tmp/"
MIGRATION_FILE = "db/migrate/create_ones_twos_set"

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

class HasManyWithSetTest < ActiveSupport::TestCase
  def setup
    PrepareActiveRecord.prepare_default_schema
    PrepareActiveRecord.run_migration(PARENT, CHILD)
  end

  test "parent class has the getter" do
    assert_respond_to One.new, "twos"
  end

  test "parent class has the setter" do
    assert_respond_to One.new, "twos="
  end

  test "child class has the getter" do
    assert_respond_to Two.new, "ones"
  end

  test "getter type" do
    assert_kind_of Array, One.new.twos
  end

  test "children can be saved" do
    15.times do
      assert Two.new.save
    end

    assert (Two.all.size == 15)
  end

  test "parent saved with empty set" do
    assert One.new(:num => 0).save
    assert One.last.twos.size == 0
  end

  test "parent saved with non-empty set" do
    record = One.new
    record.twos = Two.all
    record.num = record.twos.size
    assert record.save

    record = One.find(record.id)
    assert record.num == record.twos.size
  end

  test "parent saved with several children" do
    Two.all.each do |m|
      record = One.new(:num => 1)
      record.twos << m
      assert record.save

      record = One.find(record.id)
      assert record.num == record.twos.size
    end
  end

  test "set reuse" do
    items = Two.all

    25.times do
      master_record = One.new

      rand(items.size + 1).times do
        master_record.twos << items[rand(items.size)]
      end

      master_record.num = master_record.twos.size
      master_record.save

      master_items = master_record.twos

      set_id = master_record.send(:ones_twos_set_id)

      100.times do
        record = One.new(:num => master_items.size)
        record.twos = master_items
        record.save

        assert(record.send(:ones_twos_set_id) == set_id,
               "Set ids do not match #{ record.send(:ones_twos_set_id) } == #{ set_id }")
      end
    end
  end

  test "do not save repeated items" do
    items = Two.all
    master_record = One.new(:num => items.size)

    master_record.twos = Two.all
    master_record.twos << items
    master_record.twos << items
    master_record.twos << items
    master_record.save

    assert master_record.twos.size == items.size
  end

  test "children can see parents" do
    item = Two.create

    how_many = rand(50)

    how_many.times do
      record = One.new(:num => 1)
      record.twos << item
      record.save
    end

    assert item.ones.size == how_many, "#{ item.ones.size } != #{ how_many }"
  end

  test "items count match" do
    One.all.each do |m|
      assert m.num == m.twos.size
    end
  end
end

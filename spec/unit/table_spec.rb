# Copyright (c) 2011 - 2013, SoundCloud Ltd., Rany Keddo, Tobias Bielohlawek, Tobias
# Schmidt

require File.expand_path(File.dirname(__FILE__)) + '/unit_helper'

require 'lhm/table'

describe Lhm::Table do
  include UnitHelper

  describe 'ddl' do
    it 'should build the destination table' do
      table = 'users'
      schema = 'default'
      @table = Lhm::Table.new(table, 'id', %Q{CREATE TABLE `#{table}` (random_constraint)}, schema)
      @table.constraints['user_id'] = {:name => 'random_constraint', :referenced_column => true}
      Lhm::Table.schema_constraints(schema, {'random_constraint_lhmn' => true})
      @table.destination_ddl.must_equal %Q{CREATE TABLE `#{@table.destination_name}` (random_constraint_lhmn)}
    end
  end

  describe 'names' do
    it 'should name destination' do
      @table = Lhm::Table.new('users')
      @table.destination_name.must_equal 'lhmn_users'
    end
  end

  describe 'constraints' do
    def set_columns(table, columns)
      table.instance_variable_set('@columns', columns)
    end

    def set_references(table, references)
      table.instance_variable_set('@references', references)
    end

    it 'should be satisfied with a single column primary key called id' do
      @table = Lhm::Table.new('table', 'id')
      set_columns(@table, { 'id' => { :type => 'int(1)' } })
      @table.satisfies_pk_requirement?.must_equal true
    end

    it 'should not be satisfied if id is not numeric' do
      @table = Lhm::Table.new('table', 'id')
      set_columns(@table, { 'id' => { :type => 'varchar(255)' } })
      @table.satisfies_pk_requirement?.must_equal false
    end

    it 'should be satisfied if primary key is not called id' do
      @table = Lhm::Table.new('table', 'user_id')
      set_columns(@table, { 'user_id' => { :type => 'int(1)' } })
      @table.satisfies_pk_requirement?.must_equal true
    end

    it 'should not be satisfied with a non numeric primary key' do
      @table = Lhm::Table.new('table', 'user_id')
      set_columns(@table, { 'user_id' => { :type => 'varchar(255)' } })
      @table.satisfies_pk_requirement?.must_equal false
    end
  end
end

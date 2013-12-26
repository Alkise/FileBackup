require "rspec"
require_relative "../app/backup"

describe Backup do

  before(:all) do
    @data_catalog = "/home/alkise/Incoming/arh/"
    @backup_catalog = ENV["HOME"]
    @file_extension = ".msg"
    @backup = Backup.new(@data_catalog, @backup_catalog, @file_extension)
  end

  it 'should return a catalog name with data' do
    @backup.data_catalog.should == @data_catalog
  end

  it 'should be return a name of backup catalog' do
    @backup.backup_catalog.should == @backup_catalog
  end

  it 'should return file extension' do
    @backup.data_extensions.should have(1).items
    @backup.data_extensions.should include(".msg")
  end

  it 'should establish the  home catalog of the user by default' do
    new_backup = Backup.new("qwe", "qwe")
    new_backup.data_catalog.should == ENV["HOME"]
    new_backup.backup_catalog.should == ENV["HOME"]
  end

  it 'should write some elements into array of extension of data files' do
    new_backup = Backup.new(ENV["HOME"], @backup_catalog, ".msg", ".txt")
    new_backup.data_extensions.should have(2).items
    new_backup.data_extensions.should include(".msg")
    new_backup.data_extensions.should include(".txt")
  end

  it 'should change a data catalog path' do
    new_data_catalog = ENV["HOME"]
    @backup.data_catalog = new_data_catalog
    @backup.data_catalog.should == new_data_catalog
    @backup.data_catalog = @data_catalog
  end

  it 'should read a files (only writable) names list from catalog with data' do
    @backup.file_list.should have(113).items
  end 

end

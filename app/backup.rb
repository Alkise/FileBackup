require "zip"

class Backup
  attr_reader :data_extensions, :data_catalog, :backup_catalog
  
  def initialize(data_catalog, backup_catalog, *data_extensions)
    @data_catalog = check_catalog(data_catalog)
    @backup_catalog = check_catalog(backup_catalog)
    @data_extensions = data_extensions
  end

  def data_catalog=(data_catalog)
    @data_catalog = check_catalog(data_catalog)
  end

  def backup_catalog=(backup_catalog)
    @backup_catalog = check_catalog(backup_catalog)
  end

  def file_list
    if @data_extensions 
      extensions_re = Regexp.new(@data_extensions.join("|"))
      Dir::entries(@data_catalog).select { |filename| File.stat("#{@data_catalog}/#{filename}").writable? if (extensions_re =~ filename)}
    else
      Dir::entries(@data_catalog).drop(2)
    end
  end

  def start 
    backup_files = file_list
    unless backup_files.empty? 
      puts "Preparing #{backup_files.count} files for compression..."
      backup_archive = Time.now.strftime("#{@backup_catalog}/%d%m%y%H%M%S.zip")
      Zip::File.open(backup_archive, Zip::File::CREATE) do |zipfile|
        backup_files.each do |filename|
          begin
            canonical_filename = "#{@data_catalog}/#{filename}"
            zipfile.add(filename, canonical_filename)
          rescue Exception => e
            puts e.message
          end
        end 
        puts "Compression..."
      end
      puts "Backup archive created."
      puts "Removal of initial files..."
      backup_files.each do |filename|
        begin
          File::delete("#{@data_catalog}/#{filename}")
        rescue Exception  => e
          puts "Error: #{e.message}"
        end
      end
      backup_files.clear
      puts "Completed!"
    else
      puts "No files for backup."
    end
  end

  private

  def check_catalog(catalog)
    (Dir::exist?(catalog) && File.stat(catalog).writable?) ? catalog : ENV["HOME"]
  end
end

data_catalog = "/home/alkise/Incoming/arh/"
backup_catalog = ENV["HOME"]
Backup.new(data_catalog, backup_catalog, ".msg", ".log").start

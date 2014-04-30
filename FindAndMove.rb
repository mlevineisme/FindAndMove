#-- This program takes requirements specified in the .conf file, finds the
#   associated .rb and .xml files, and copies them to a single file location

require 'FileUtils'

def print_err errorMsg
   puts errorMsg
   puts $!
   puts $!.backtrace
end

CURRENT_FOLDER = FileUtils.pwd
SOURCE_FOLDER = "c:/P4/test/pcatest/7.0/team/automation/TestScripts"
DESTINATION_FOLDER = "C:/TestRuns/MovedScripts"
puts "The Scriptlet Source Folder Is: #{SOURCE_FOLDER}"
puts "Files specified in the .conf file will be copied to the destination folder: #{DESTINATION_FOLDER}\n\n"
SCRIPTS_CONFIG_NAME = "#{File.basename(__FILE__, ".rb")}.conf"

#-- Open the directory configuration file
begin
   SCRIPTS_CONF_FILE = File.open("#{CURRENT_FOLDER}/#{SCRIPTS_CONFIG_NAME}")
rescue
   print_err "A problem arose when trying to open the scripts configuration file.
              Please verify it exists and is named to match the script file"
end

#-- Create an array of the desired .rb and .xml files
script_names = Array.new
SCRIPTS_CONF_FILE.each_line {|line| script_names << line.chomp}
script_files = []
script_names.each {|line|
   script_files << "#{line}.rb"
   script_files << "#{line}.xml"
}

#-- Copy the source files into the destination directory
script_files.each do |file|
   full_path = Dir.glob("#{SOURCE_FOLDER}/**/#{file}").first

   begin
      #-- Copy the files to their new directory
         FileUtils.cp full_path, DESTINATION_FOLDER, :preserve => true
         FileUtils.chmod("u=wrx,go=rx", "#{DESTINATION_FOLDER}\\#{file}") if (File.exist?("#{DESTINATION_FOLDER}\\#{file}")) and !(File.writable?("#{DESTINATION_FOLDER}\\#{file}"))
         puts "#{full_path} was successfully copied to #{DESTINATION_FOLDER}"
   rescue
      print_err "A problem arose when trying to copy the files"
   end
end
SCRIPTS_CONF_FILE.close
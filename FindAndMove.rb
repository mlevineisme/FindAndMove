#-- This program takes requirements specified in the .conf file, finds the
#   associated .rb and .xml files, and copies them to a single file location

require 'FileUtils'

def print_err errorMsg
   puts errorMsg
   puts $!
   puts $!.backtrace
end

#-- You may need to change the following variables as file extensions/locations change
extensions_to_move = [".rb", ".xml"]
source_folder = "c:/P4/test/pcatest/7.0/team/automation/TestScripts"
DESTINATION_FOLDER = "C:/TestRuns/MovedScripts"

puts "Files matching the .conf found in #{source_folder} will be copied to #{DESTINATION_FOLDER}\n\n"

#-- Open the directory configuration file
begin
   SCRIPTS_CONF_FILE = File.open("#{FileUtils.pwd}/#{File.basename(__FILE__, ".rb")}.conf")
rescue
   print_err "A problem arose when trying to open the scripts configuration file.
              Please verify it exists and is named to match the script file"
end

#-- Create an array of the desired .rb and .xml files
script_names = Array.new
SCRIPTS_CONF_FILE.each_line {|line| script_names << line.chomp}
script_files = []
script_names.each {|line|
   extensions_to_move.each {|ext|
      script_files << "#{line}#{ext}"
   }
}

#-- Copy the source files into the destination directory
begin
   script_files.each do |file|
      full_path = Dir.glob("#{source_folder}/**/#{file}").first
      FileUtils.cp full_path, DESTINATION_FOLDER, :preserve => true
      FileUtils.chmod("u=wrx,go=rx", "#{DESTINATION_FOLDER}\\#{file}") if (File.exist?("#{DESTINATION_FOLDER}\\#{file}")) and !(File.writable?("#{DESTINATION_FOLDER}\\#{file}"))
      puts "#{full_path} was successfully copied to #{DESTINATION_FOLDER}"
   end
rescue
   print_err "A problem arose when trying to copy the files"
end
SCRIPTS_CONF_FILE.close
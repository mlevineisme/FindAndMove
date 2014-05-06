#-- This program takes requirements specified in the .conf file, finds the
#   associated .rb and .xml files, and copies them to a single file
#   location, preserving the file paths after the specified end point

require 'FileUtils'

def print_err errorMsg
   puts errorMsg
   puts $!
   puts $!.backtrace
end

#-- You may need to change the following variables as file extensions/locations change
extensions_to_move = [".rb", ".xml"]
source_folder = "c:/P4/test/pcatest/7.0/team/automation/TestScripts"
DESTINATION_FOLDER = "C:\\TestRuns\\MovedScripts\\"
LAST_PATH_SECTION_TO_REMOVE = "TestScripts"
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
#   FileUtils::mkdir(DESTINATION_FOLDER) unless (Dir.exists?(DESTINATION_FOLDER))
   filesEqual = []
   script_files.each do |file|
      full_file_path = Dir.glob("#{source_folder}/**/#{file}").first
      full_path_array = full_file_path.split("/").collect {|part_path| part_path unless part_path.eql?(file)}.compact
      relevant_index = full_path_array.find_index(LAST_PATH_SECTION_TO_REMOVE)+1
      relevant_path = full_path_array.slice(relevant_index, full_path_array.length).join("\\")
      FileUtils::mkdir_p(DESTINATION_FOLDER + relevant_path) unless (Dir.exists?(DESTINATION_FOLDER + relevant_path))

      copy_successful = false
      begin
         copy_successful = true if (FileUtils.cp full_file_path, (DESTINATION_FOLDER + relevant_path), :preserve => true)
      rescue TypeError
         print_err "Error reading the source file. Do the source files exist in the local workspace for team?"
      rescue
         print_err "A problem arose when trying to copy the files"
      end

      if copy_successful.eql?(true)
         begin
            FileUtils.chmod("u=wrx,go=rx", "#{DESTINATION_FOLDER + relevant_path}\\#{file}") if (File.exist?("#{DESTINATION_FOLDER + relevant_path}\\#{file}")) and !(File.writable?("#{DESTINATION_FOLDER + relevant_path}\\#{file}"))
             if (File.mtime("#{DESTINATION_FOLDER + relevant_path}\\#{file}".gsub("/", "\\")).eql?(File.mtime(full_file_path.gsub("/", "\\"))))
               puts "#{full_file_path} was successfully copied to #{DESTINATION_FOLDER + relevant_path}"
            else
               puts "#{full_file_path} could not be copied to #{DESTINATION_FOLDER + relevant_path}!!!"
            end
         rescue
            print_err "A problem arose when trying to change destination file permissions and verify the copy"
         end
      end
   end
rescue
   print_err "A problem arose when trying to copy the files"
ensure
   SCRIPTS_CONF_FILE.close
end
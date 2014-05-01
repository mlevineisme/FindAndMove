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
DESTINATION_FOLDER = "C:\\TestRuns\\MovedScripts"
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
   FileUtils::mkdir(DESTINATION_FOLDER) unless (Dir.exists?(DESTINATION_FOLDER))
   filesEqual = []
   script_files.each do |file|
      full_path = Dir.glob("#{source_folder}/**/#{file}").first

      copy_successful = false
      begin
         copy_successful = true if (FileUtils.cp full_path, DESTINATION_FOLDER, :preserve => true)
      rescue TypeError
         print_err "Error reading the source file. Do the source files exist in the local workspace for team?"
      rescue
         print_err "A problem arose when trying to copy the files"
      end

      if copy_successful.eql?(true)
         begin
            FileUtils.chmod("u=wrx,go=rx", "#{DESTINATION_FOLDER}\\#{file}") if (File.exist?("#{DESTINATION_FOLDER}\\#{file}")) and !(File.writable?("#{DESTINATION_FOLDER}\\#{file}"))
             if (File.mtime("#{DESTINATION_FOLDER}/#{file}".gsub("/", "\\")).eql?(File.mtime(full_path.gsub("/", "\\"))))
               puts "#{full_path} was successfully copied to #{DESTINATION_FOLDER}"
            else
               puts "#{full_path} could not be copied to #{DESTINATION_FOLDER}!!!"
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
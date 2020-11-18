puts "Whats the path to the .app? (ex:/Applications/iMovie.app)"
which_app = gets.chomp # chomp removes the trailing newline
# single quotes cause problems, so replace all the single quotes
which_app = which_app.gsub(/'/,"'\"'\"'") 

puts "Should I run the commands or show you the commands?\n(choose either \"show\" or \"run\")"
@show_or_run = gets.chomp # chomp removes the trailing newline
puts

# create a function that will sign a specific file/folder
# basically this whole app just calls this function on a bunch of files/folders
def sign(filepath)
    if @show_or_run =~ /run/
        # run the command
        puts `sudo codesign -f -s - '#{filepath}'`.chomp
    else
        # print out the command to run
        puts "sudo codesign -f -s - '#{filepath}'"
    end
end

# 
# figure out where the app executable is
# 
executable_statment = `codesign -d '#{which_app}' 2>&1`.chomp
# ^should return something like: Executable=/Applications/Keynote.app/Contents/MacOS/Keynote

# remove the Executable= part
executable_path = executable_statment.sub(/^Executable=/,"")
# resign the executable
puts "This might take a hot minute (if you picked the 'run' option)"
sign(executable_path)

# 
# re-sign (or atleast try to re-sign) all the frameworks
# 
path_to_frameworks = "#{which_app}/Contents/MacOS/../Frameworks/"
all_subfiles_and_folders = `find '#{path_to_frameworks}' -iname "*"`.split("\n")
list_of_frameworks = `ls -1 '#{path_to_frameworks}'`.split("\n")
# ^should end up as something like:
#     EquationKit.framework
#     TSAccessibility.framework
#     TSApplication.framework
#     TSCalculationEngine.framework
#     TSCharts.framework
#     TSCoreSOS.framework
#     TSDrawables.framework
#     TSKit.framework
#     TSPersistence.framework
#     TSStyles.framework
#     TSTables.framework
#     TSText.framework
#     TSUtility.framework
#     libswiftAVFoundation.dylib
#     libswiftAppKit.dylib
#     libswiftCloudKit.dylib
#     libswiftContacts.dylib
#     libswiftCore.dylib
#     libswiftCoreAudio.dylib
#     libswiftCoreData.dylib
#     libswiftCoreFoundation.dylib
#     libswiftCoreGraphics.dylib
#     libswiftCoreImage.dylib
#     libswiftCoreLocation.dylib
#     libswiftCoreMedia.dylib
#     libswiftDarwin.dylib
#     libswiftDispatch.dylib
#     libswiftFoundation.dylib
#     libswiftIOKit.dylib
#     libswiftMetal.dylib
#     libswiftObjectiveC.dylib
#     libswiftQuartzCore.dylib
#     libswiftXPC.dylib
#     libswiftos.dylib
#     libswiftsimd.dylib

for each_name in list_of_frameworks
    # its a framework, lets resign it's content
    if each_name =~ /\.framework$/
        base_name = each_name.sub(/\.framework$/,"")
        path_to_framework = "#{which_app}/Contents/MacOS/../Frameworks/#{each_name}/Versions/A/#{base_name}"
        sign(path_to_framework)
    # if it is a dynamic library it also needs re-signing directly
    elsif each_name =~ /\.dylib$/
        path_to_dylib = "#{which_app}/Contents/MacOS/../Frameworks/#{each_name}"
        sign(path_to_dylib)
    end
end


puts "-------------------------"
puts " Don't leave just yet"
puts "-------------------------"
puts "try opening the app. If it still fails, I'll try a more brute-force method"
puts "Should I try the more brute force method? (yes or no)"
answer = gets.chomp
if answer =~ /y|yes/
    puts "Attempting to sign all the framework files"
    counter = 0
    for each_name in all_subfiles_and_folders
        counter += 1
        if each_name =~ /\.plist$|\/_CodeSignature$|\/CodeResources$|\.lproj$/
            # skip those^ kinds of files
            next
        end
        percent_complete = ((counter/all_subfiles_and_folders.length) * 100).round(2)
        puts "#{percent_complete}%: on #{counter} of #{all_subfiles_and_folders.length}"
        # try signing absolutely everything else
        # (probably a dumb idea but whatever, should sign everything that needed to be signed)
        sign(each_name)
    end
end

puts "--------------------------------------------------"
puts "        Okay, DONE! Try opening the app!"
puts "--------------------------------------------------"
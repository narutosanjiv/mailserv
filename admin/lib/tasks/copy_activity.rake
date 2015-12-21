require 'fileutils'


def graph_file_copy(filenames)
  destination_dir = Dir.pwd + "/" + "public/images/munin/"
  filenames.each do|file|
      FileUtils.cp(MUNIN_GRAPH_DIRECTORY + "/" + file, destination_dir)
  end
end

namespace :munin do
  desc "Copying the munin graph"
 
  task :copy_daily => :environment do 
    filenames = ["cpu-day.png", "memory-day.png", "swap-day.png"]
    graph_file_copy(filenames)
  end  


  task :copy_weekly => :environment do 
    filenames = ["cpu-week.png", "memory-week.png", "swap-week.png"]
    graph_file_copy(filenames)
  end  
  
  task :copy_monthly => :environment do 
    filenames = ["cpu-month.png", "memory-month.png", "swap-month.png"]
    graph_file_copy(filenames)
  end

  task :copy_yearly => :environment do 
    filenames =  ["cpu-year.png", "memory-year.png", "swap-year.png"]
    graph_file_copy(filenames)
  end
end

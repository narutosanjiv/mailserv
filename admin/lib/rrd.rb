#Implementation of rrdtool create, update, plot graph
#Correct way should have been implementing the ruby-c binding


require 'open3'

class NoFileError < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end
end

class MissingInstallError < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end
end
   
class InvalidArgumentError < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end
end

class InvalidCommand < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end 
end 

class RRD
  def initialize(rrdtool=nil) 

    @rrd_command = rrdtool || "rrdtool"
    unless command?(@rrd_command)
      raise MissingInstallError.new(self), "Unable to find 'rrdtool' in path." 
    end

  end

  def graph

  end    

  def create(filename, *args)
    call_rrd_func("create", filename, args)
  end
  
  def update(filename, *args)
    call_rrd_func("update", filename, args)
  end     

  def run_command(args)
    argument = args.join(' ') 
    stdout_and_stderr_str, status = Open3.capture2e(@rrdtool, argument)
    unless status.exitstatus.zero?  
      raise InvalidCommand.new(self),  stdout_and_stderr_str        
    end 
  end

  def command?(name)
    `which #{name}`
    $?.success?
  end
 
  def call_rrd_func(rrdtool_command, filename, args)
    if filename.blank?
      raise NoFileError.new(self), "File not present."
    end

    if args.length.zero?
      raise InvalidArgumentError.new(self), "Invalid empty arguments." 
    end 
    args.unshift(filename)  
    args.unshift(rrdtool_command)  
    run_command(args)
  end
 
  private :command?, :run_command, :call_rrd_func

end

require File.expand_path(File.join(File.dirname(__FILE__), '../../app/engine/workflow_engine'))

begin
  ARGV.each do |arg|
    if arg.eql?('production') || arg.eql?('development')
      WorkFlowEngine.new
      break
    end
  end
end

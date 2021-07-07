require 'smaug.rb'
require 'smaug/draco/lib/draco/benchmark.rb'

def tick args
  args.outputs.background_color = [100, 100, 100]

  args.outputs.labels  << [640, 500, 'Draco API Demo', 5, 1]
  args.outputs.labels  << [640, 460, 'Open http://localhost:9001/draco/entities in your browser', 5, 1]

  args.state.world ||= Game.new
  args.state.world.tick(args) unless args.state[:world].nil?
  args.state.world = nil if $gtk.files_reloaded.length > 0
end

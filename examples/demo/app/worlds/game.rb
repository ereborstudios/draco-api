class Game < Draco::World
  include Draco::API
  include Draco::Benchmark

  route '/draco' do

    route '/health' { action -> { 200 } }

    route '/entities' do
      action -> do
        grouped = world.entities
          .map(&:serialize)
          .group_by { |e| Draco.underscore(e[:class]) }
          .transform_values do |group|
            {
              name: group[0][:class],
              count: group.count,
              items: group,
            }
          end
        {
          entities: grouped.values
        }
      end

      route '/filter/:component' do
        action -> do
          world.filter(Draco::Component.class.const_get(Draco.camelize(params.component))).to_a
        end
      end

      route '/:id' do
        action -> do
          world.entities[params.id.to_i].first
        end
      end
    end

    route '/system_timers' do
      action -> { args.state.system_timers_last.sort }
    end

    route '/foobar' do
      action -> {
        "<strong>Foo</strong>"
      }
    end
  end

  def initialize
    super
  end

  def tick(args)
    super(args)
    args.state.system_timers_last = args.state.world.system_timers
  end
end

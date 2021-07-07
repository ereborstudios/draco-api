module Draco
  module API

    def self.included(mod)
      mod.extend(ClassMethods)
      mod.prepend(InstanceMethods)
      mod.instance_variable_set(:@default_routes, [])
    end

    module ClassMethods

      class EntityBuilder
        def self.component(component, opts = {})
          opts[:attributes] ||= []
          opts[:attributes].each do |name|
            define_method name do |v|
              @entity.components[component].send("#{name}=".to_sym, v)
            end
          end
        end

        def self.nested(entity_class_name, opts = {})
          define_method entity_class_name do |&block|
            klass = eval(Draco.camelize(entity_class_name.to_s))
            builder = opts[:builder] ? eval(Draco.camelize(opts[:builder].to_s)) : self.class
            @children << Docile.dsl_eval(builder.new(klass, @entity), &block)
          end
        end

        def initialize(klass = Draco::Entity, parent = nil)
          @entity = klass.new
          @entity.components << Tree.new(parent_id: (parent ? parent.id : nil))
          @entity.instance_variable_set :@parent, parent
          @entity.instance_eval do
            def parent
              @parent
            end
          end
          @children = []
        end

        def build(entities)
          entities.push(@entity)
          @children.each do |c|
            c.build(entities)
          end
          @entity
        end

        def tag(t)
          @entity.components << Draco.Tag(t).new
        end
      end

      class RouteBuilder < EntityBuilder
        component :match, attributes: %w[uri]
        component :response, attributes: %w[action headers]
        #nested :route

        def route(uri, &block)
          child = Docile.dsl_eval(self.class.new(Route, @entity), &block)
          child.uri uri
          @children << child
        end
      end

      def route(uri, &block)
        @default_routes ||= []
        r = Docile.dsl_eval(RouteBuilder.new(Route), &block).build(@default_routes)
        r.match.uri = uri
      end

    end

    module InstanceMethods
      def after_initialize
        super

        self.class.instance_variable_get(:@default_routes).each do |route|
          #puts "Adding #{route.inspect}"
          @entities.add(route)
        end

        @systems << ApiRouter
      end

      #def before_tick(context)
      #  puts "tick"
      #  super
      #end

    end
  end
end

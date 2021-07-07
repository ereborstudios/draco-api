module Draco
  module API
    class Response
      attr_reader :request, :params, :world, :args

      attr_accessor :status, :body, :headers

      def initialize(request, params, world, args)
        @request = request
        @params = params
        @world = world
        @args = args

        @status ||= 200
        @body ||= ''
        @headers ||= {}
      end

      def json(object)
        @headers['Content-Type'] = 'application/json'
        @body = object.to_json
      end
    end

    class NotFound < StandardError; end;
  end
end

class ApiRouter < Draco::System
  include Draco::Benchmark::SystemPlugin
  filter Match

  def tick args
    return unless args.inputs.http_requests

    args.inputs.http_requests.each do |req|
      begin
        match = router(entities).match req.uri
        raise Draco::API::NotFound unless match

        route = world.entities[match.route].first

        response = Draco::API::Response.new(req, match, world, args)

        action_result = Docile.dsl_eval_with_block_return(response, &route.response.action)

        if action_result.kind_of? Integer
          response.status = action_result
        elsif action_result.kind_of? String
          response.body = action_result
        else
          response.json(action_result)
        end

        req.respond response.status, response.body, response.headers
      rescue Draco::API::NotFound
        req.respond 404, 'Not found'
      rescue
        req.respond 500, 'An error occurred'
      end
    end
  end

  def router(entities)
    return @router unless @router.nil?

    @router = Router.new
    entities.each do |entity|
      @router.add_route entity.uri, { route: entity.id }
    end

    @router
  end
end

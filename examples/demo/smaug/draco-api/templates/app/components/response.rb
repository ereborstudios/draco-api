class Response < Draco::Component
  attribute :headers, default: {}
  attribute :action, default: -> {}
end

# Draco API

> Declarative routing and data serialization for the embedded HTTP server

Adding a REST API to your game makes it possible for other programs to inspect and manipulate the current game state while the game is running.

## Overview

* Declare a route with `route "/string" # {...}` to match an exact string
* Use `route "/resource(/:id(.:format))" # {...}` to match optional substrings and capture params
* You can nest additional routes to namespace them within the parent scope:

    ```ruby
    route '/entities' do
      route '/players' do
        route '/:id' # '/entities/players/:id'
      end
    end
    ```
* Call `action -> { ... }` within a route to handle requests, returning a response.
  * If an action returns an Integer, it will be used as the http status code with an empty response
  * If an action returns a String, it will be sent as HTML text
  * Any other kind of object will be serialized to JSON

## Example

A simple API with a few different routes

```ruby
class Game < Draco::World
  include Draco::API

  route '/foo' do
    route '/success' { action -> { 200 } }
    route '/error' { action -> { 500 } }

    route '/string' { action -> { "<strong>OK</strong>" } }
    route '/:id' do
      action -> do
        world.entities[params.id.to_i].first
      end
    end
  end

end
```

Check the `examples/` directory for a complete demo containing several more examples you can learn from.

---

## Installation

If you don't already have a game project, run `smaug new` to create one.

```bash
$ smaug add draco
$ smaug add draco-api
```


```ruby
# app/main.rb
require 'smaug.rb'

def tick args
  args.state.world ||= HelloWorld.new
  args.state.world.tick(args)
end
```

Next, create a World and include `Draco::API`.

```ruby
# app/worlds/hello_world.rb
class HelloWorld < Draco::World
  include Draco::API
  route '/hello' { action -> { 'Hello' } }
end
```

Start the game with `smaug run`, and navigate to http://localhost:9001/hello to see the result.

## Credit

This package contains code originally derived from the following projects under the MIT license:

* https://github.com/rails/activesupport-json_encoder/
* https://github.com/onyxblade/Mrouter
* https://github.com/ms-ati/docile
* https://github.com/onyxblade/Mrouter

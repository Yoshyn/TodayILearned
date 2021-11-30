# frozen_string_literal: true

require 'json'
require 'open-uri'

class Application
  def self.call(env)
    req = Rack::Request.new(env)
    case req.path_info
    when "/"      
      response = {
       host: ENV["HOST"],
       instance_id: ENV["INSTANCE_ID"], 
       public_ip: ENV["PUBLIC_IP"], 
       ecs_metadata: ENV["ECS_METADATA"],
       hello: "You can refresh and check if the load balancer work well."
      }
      [200, {"Content-Type" => "application/json"}, [response.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, ["I'm Lost!"]]
    end
  end
end
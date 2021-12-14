# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'open3'

# PGPASSWORD='6!7vB1M#KdO$YGNw' psql -h 127.0.0.1 -p 5432 -U postgres -c 'DROP DATABASE demo_application'
# PGPASSWORD='6!7vB1M#KdO$YGNw' psql -h 127.0.0.1 -p 5432 -U postgres -c 'CREATE DATABASE demo_application'
# PGPASSWORD='6!7vB1M#KdO$YGNw' psql -h 127.0.0.1 -p 5432 -U postgres -d demo_application -f schema.sql
# PGHOST="127.0.0.1" PGPASSWORD='6!7vB1M#KdO$YGNw' PGPORT="5432" PGUSER="postgres" DB_NAME="demo_application" ruby config.ru
# docker build -f Dockerfile -t yoshyn/demo-application .
# docker run --env PGHOST="host.docker.internal" --env PGPASSWORD="6!7vB1M#KdO\$YGNw" --env PGPORT="5432" --env PGUSER="postgres" --env DB_NAME="demo_application" -p 8080:8080 -it --rm yoshyn/demo-application

class Application

  DB_HOST = ENV['PGHOST']
  DB_PORT = ENV['PGPORT']
  DB_USER = ENV['PGUSER']
  DB_NAME = ENV['DB_NAME']

  def self.database_alive?
    query = "SELECT version() AS postgresql_version;"
    stdout, stderr, status = Open3.capture3("psql -h #{DB_HOST} -p #{DB_PORT} -U #{DB_USER} -c '#{query}'")
    if !status.success?
      puts "DbConnectionError (#{status}) : #{stderr}"
    end
    status.success?
  end

  def self.database_info
    query = "SELECT table_schema || '.' || table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema');";
    Open3.capture3("psql -h #{DB_HOST} -p #{DB_PORT} -U #{DB_USER} -d #{DB_NAME} -c \"#{query}\"")
  end

  def self.call(env)
    req = Rack::Request.new(env)
    case req.path_info
    when "/"      
      response = {
       host: ENV["HOST"],
       instance_id: ENV["INSTANCE_ID"], 
       public_ip: ENV["PUBLIC_IP"], 
       ecs_metadata: ENV["ECS_METADATA"],
       database: self.database_alive?,
       hello: "You can refresh and check if the load balancer work well.",
      }
      [200, {"Content-Type" => "application/json"}, [response.to_json]]
    when "/db"
      result = database_info
      response = {
        status: result[2],
        stderr: result[1],
        stdout: result[0]
      }
      [200, {"Content-Type" => "application/json"}, [response.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, ["I'm Lost!"]]
    end
  end
end
# Write config/database.yml based on $DATABASE_URL
# Replaces the 80-line giant that is database_support.rb

require 'uri'
require 'json'

puts "Writing config/database.yml from $DATABASE_URL"
uri = URI.parse ENV['DATABASE_URL']
ymlfile = File.join(File.join(ENV['HOME'], 'config', 'database.yml'))
adapter = if uri.scheme == "mysql"
            "mysql2"
          else
            "postgresql"
          end
_, _, database = uri.path.rpartition "/"

File.open(ymlfile, 'w') do |fh|
  fh.puts("production:
  adapter: #{adapter}
  encoding: utf8
  pool: 5
  reconnect: false
  host: #{uri.host}
  port: #{uri.port}
  username: #{uri.user}
  password: #{uri.password}
  database: #{database}
")
end

# {name: uri, name1: uri1}

ext = ENV['EXTERNAL_DATABASE_CONFIG'] 

begin
ext = JSON.parse(ext) if ext
rescue
end

if ext.is_a?(Hash)
  File.open(ymlfile, 'a') do |fh|
    ext.each do | name, cfg |
      uri = uri.parse cfg
      adapter = if uri.scheme == "mysql"
        "mysql2"
      else
        uri.scheme
      end
      _, _, database = uri.path.rpartition "/"
      
      fh.puts("#{name}:
        adapter: #{adapter}
        encoding: utf8
        pool: 5
        reconnect: false
        host: #{uri.host}
        port: #{uri.port}
        username: #{uri.user}
        password: #{uri.password}
        database: #{database}
      ")
    end
  end
end

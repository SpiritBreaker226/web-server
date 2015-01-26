require 'socket'                                    # Require socket from Ruby Standard Library (stdlib)

host = 'localhost'
port = 2000

server = TCPServer.open(host, port)                 # Socket to listen to defined host and port
puts "Server started on #{host}:#{port} ..."        # Output to stdout that server started

loop do                                             # Server runs forever
  client = server.accept                            # Wait for a client to connect. Accept returns a TCPSocket

  lines = []

  while (line = client.gets.chomp) && !line.empty?  # Read the request and collect it until it's empty
    lines << line
  end

  puts lines                                        # Output the full request to stdout

  filename = lines[0].gsub(/GET \//, "").gsub(/HTTP*\/\d.\d/, "")
  header = []

  if File.exist?(filename)
  	response_body = File.read(filename)

  	header << "HTTP/1.1 200 OK"
  	header << "Content-Type: text/html" # should reflect the appropriate file type
  else
  	response_body = "File Not Found\n"
  	
  	header << "HTTP/1.1 404 Not Found"
  	header << "Content-Type: text/plain" # is always text/plain
  end

  header << "Content-Length: #{response_body.size}"
  header << "Connection: close"
  header = header.join("\r\n")

  response = [header, response_body].join("\r\n\r\n")

  client.puts(response) # Output the current time to the client
  client.close                                      		# Disconnect from the client
end

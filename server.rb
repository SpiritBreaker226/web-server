require 'socket'                                    # Require socket from Ruby Standard Library (stdlib)

class Server
	def initialize(host, port)
		@host = host
		@port = port
	end
	
	def start_server
		server = TCPServer.open(@host, @port)                 # Socket to listen to defined host and port
		puts "Server started on #{@host}:#{@port} ..."        # Output to stdout that server started

		loop do                                             # Server runs forever
		  client = server.accept                            # Wait for a client to connect. Accept returns a TCPSocket

		  lines = get_clients_request_header(client)
		  puts lines                                        # Output the full request to stdout

		  filename = get_client_file(lines[0])
		  header_content = get_content_from(filename)
		  
		  client.puts(header_content) # Output the current time to the client
		  client.close                                      		# Disconnect from the client
		end
	end

	private

	def get_clients_request_header(client)
	  request_lines = []

	  while (line = client.gets.chomp) && !line.empty?  # Read the request and collect it until it's empty
	    request_lines << line
	  end

	  request_lines
	end

	def get_content_from(filename)
		filename = "index.html" if filename.empty?

		header = []

	  if File.exist?(filename)
	  	response_body = File.read(filename)

	  	header << "HTTP/1.1 200 OK"
	  	header << "Content-Type: #{get_content_type(filename)}" # should reflect the appropriate file type
	  else
	  	response_body = "File Not Found\n"

	  	header << "HTTP/1.1 404 Not Found"
	  	header << "Content-Type: text/plain" # is always text/plain
	  end

	  header << "Content-Length: #{response_body.size}"
	  header << "Connection: close"

	  [header.join("\r\n"), response_body].join("\r\n\r\n")
	end

	def get_content_type(filename)
		case File.extname(filename)
		when ".html", ".htm" then "text/html"
		when ".css" then "text/css"
		when ".jpg", ".jpeg" then "mage/jpeg"
		when ".png" then "image/png"
		when ".gif" then "image/gif"
		when ".json" then "application/json"
		when ".js" then "application/javascript"
		when ".ico" then "image/x-icon"
		else
			"text/plain"
		end
	end

	def get_client_file(first_line_from_client_header)
		first_line_from_client_header.gsub(/GET \//, "").gsub(/\ HTTP.*/, "")
	end
end

localhost = Server.new("localhost", 2000)
localhost.start_server

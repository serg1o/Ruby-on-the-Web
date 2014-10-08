require 'socket'
require 'mime/types'
require 'json'

server = TCPServer.open(2000)  # Socket to listen on port 2000

loop do
  client = server.accept       # Wait for a client to connect
  request = client.read_nonblock(256)
  req_lines = request.split("\r\n\r\n")
  verb, path, protocol = req_lines.first.split
  case verb
    when "GET" then

      path[0] == "/" ? file = path[1..-1] : file = path
      mime_type = MIME::Types.type_for(file).first.content_type
      if File.exist?(file)
        f = File.open(file, "rb")
        client.print "HTTP/1.1 200 OK\r\n"
        client.print "Content-Type: #{mime_type}\r\n"
        client.print "Content-Length: #{f.size.to_s}\r\n\r\n"
        IO.copy_stream(file, client)
      else
        client.print "HTTP/1.1 404 Not Found\r\n"
      end
    when "POST" then
      body = req_lines.last
      puts body
      params = Hash.new
      params = JSON.parse(body)
      puts params.inspect
      viking = "<li>Viking's name: #{params["viking"]["name"]}</li><li>email: #{params["viking"]["email"]}</li>"
      file = "data/thanks.html"
      if File.exist?(file)
        f = File.open(file, "rb")
        text = f.read
        replace = text.scan(/<%= +?yield +?%>/)
        text.sub!(replace.first, viking)
        client.puts(text)
      end
    else
  end

  
#  client.puts(Time.now.ctime)  # Send the time to the client
#  client.puts "Closing the connection. Bye!"
#  puts "message sent"
  client.close                 # Disconnect from the client
end


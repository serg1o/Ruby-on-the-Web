require 'socket'
require 'json'
 
#host = 'www.tutorialspoint.com'     # The web server
host = "localhost"
port = 2000
=begin                      
path = "/index.html"                 # The file we want 

# This is the HTTP request we send to fetch a file
request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host,port)  # Connect to server

socket.print(request)               # Send request
response = socket.read              # Read complete response
puts response.inspect
# Split response at first blank line into headers and body
headers,body = response.split("\r\n\r\n", 2) 
print body                          # And display it

=end

puts "Do you wish do download a file (d) or upload a form (u)?"
choice = gets.chomp

if choice.downcase == "d"
  path = "/data/thanks.html"

  request = "GET #{path} HTTP/1.0\r\n\r\n"

  socket = TCPSocket.open(host,port)  # Connect to server

  socket.print(request)               # Send request
  response = socket.read              # Read complete response
  headers,body = response.split("\r\n\r\n", 2)
  parts_headers = headers.split("\r\n")
  header_status = parts_headers.first
  status = header_status.split[1]
  case status
    when "200" then print body
    else
      puts "The server responded with the following error message:\n"
      puts header_status
  end
else
  puts "Write the viking's name:"
  name = gets.chomp
  puts "Write the viking's email:"
  email = gets.chomp
  vikings = Hash.new
  viking_data = Hash.new
  viking_data[:name] = name
  viking_data[:email] = email
  vikings[:viking] = viking_data
  viking_json = vikings.to_json
  path = "/data/thanks.html"
  req = "POST #{path} HTTP/1.0\r\n\r\n" + "Content-Length: #{viking_json.size}\r\n\r\n" + "#{viking_json}"
  socket = TCPSocket.open(host,port)  # Connect to server

  socket.print(req)               # Send request
  response = socket.read #wait for response
  puts response
end
  


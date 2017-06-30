defmodule Server do
  def start do
    receive do
      {client, request} ->
        IO.puts "Server: received"
        send client, {:connected, "Request received: #{request}"}
    end
  end
end

defmodule Client do
  def connect(server) do
    IO.puts "Client: sending"
    send server, {self(), "GET /products"}
    IO.puts "Client: message sent"
    response_listener()
  end

  def response_listener do
    receive do
      {:connected, message} ->
        IO.puts "Client: message received from server [#{message}]"
    end
  end
end

pid_server = spawn(Server, :start, [])
spawn(Client, :connect, [pid_server])

defmodule Server do
  def start do
    receive do
      {client_id, client, request} ->
        IO.puts "Server: Request received from [#{client_id}]: #{request}"
        send client, {:connected, "done!"}
      start()
    end
  end
end

defmodule Client do
  def connect(server, myid) do
    send server, {myid, self(), "command"}
    response_listener(myid)
  end

  def response_listener(id) do
    receive do
      {:connected, message} ->
        IO.puts "Client[#{id}]: #{message}"
      after 1 ->
        IO.puts "Client[#{id}]: The server is busy"
      end
  end
end


defmodule Spawner do
  def spawn_clients(0, _) do end
  def spawn_clients(n, pid_server) do
    spawn(Client, :connect, [pid_server, n])
    spawn_clients(n-1, pid_server)
  end
end

#One Server to many Clients
pid_server = spawn(Server, :start, [])
Spawner.spawn_clients(29, pid_server)


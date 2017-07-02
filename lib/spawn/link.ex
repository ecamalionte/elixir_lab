defmodule Link do
  import :timer, only: [sleep: 1]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    #without _link, you will not know about exit(:boom)
    spawn_link(Link, :sad_function, [])
    receive do
      msg -> IO.puts "MESSAGE RECEIVED: #{inspect msg}"
    after 1000 ->
      IO.puts "Nothing happened as far as I am concerned"
    end
  end
end

Link.run

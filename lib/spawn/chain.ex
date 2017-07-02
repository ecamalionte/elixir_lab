defmodule Chain do
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
  end

  def create_process(n) do
    last = Enum.reduce 1..n, self(),
    fn (_, next_pid) ->
      spawn(Chain, :counter, [next_pid])
    end

    send last, 0 #start the count by sending a zero to the last process

    receive do # and wait for the result to come back to us
      result when is_integer(result) -> "Result is #{result}"
    end
  end

  def run(n) do
   IO.puts inspect :timer.tc(Chain, :create_process,[n])
  end
end

Enum.reduce 1..100, 0, fn (n,_) -> Chain.run(n) end

defmodule FibSolver do
  def fib(scheduler) do
    send scheduler, {:ready, self()}
    receive do
      {:fib, n, client} ->
        send client, {:answer, n, fib_calc(n), self() }
        fib(scheduler)
      {:shutdown} -> exit(:normal)
    end
  end

  defp fib_calc(0), do: 0
  defp fib_calc(1), do: 1
  defp fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)
end

defmodule Scheduler do

  # spawns a quantity of process to prepare the job(queue) execution
  def run(num_process, module, func, queue_to_calculate) do
    (1..num_process)
    |> Enum.map(fn(_) -> spawn(module, func, [self()]) end)
    |> schedule_processes(queue_to_calculate, [])
  end

  defp schedule_processes(processes, queue, results) do
    receive do
      # while has work in the queue
      {:ready, pid} when length(queue) > 0 ->
        [next|tail] = queue
        send pid, {:fib, next, self()}
        schedule_processes(processes, tail, results)

      # when has no more work to do: send a shutdown
      {:ready, pid} ->
        send pid, {:shutdown}
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          Enum.sort(results, fn {n1, _}, {n2, _} -> n1 <= n2 end)
        end

      #when receive a answer, collect the output and accumulate in results
      {:answer, number, output, _pid} ->
        schedule_processes(processes, queue, [{number, output} | results])
    end
  end
end

#produce some input list
queue_to_calculate = List.duplicate(37,20)

Enum.each 1..10, fn num_processes
  -> {time, result} = :timer.tc(Scheduler, :run, [num_processes, FibSolver, :fib, queue_to_calculate])

  if num_processes == 1 do
    IO.puts inspect result
    IO.puts "\n # time(s)"
  end

  :io.format "~2B ~.2f~n", [num_processes, time/1000000.0]
end


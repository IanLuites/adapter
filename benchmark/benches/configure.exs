IO.puts("""
====
Benchmark configuration.
====
Note: There is no `:get_compiled` bench,
      because it can't be runtime configured.
""")

Benchee.run(
  %{
    "Reference" => fn -> Application.put_env(:benchmark, :reference, BenchReference.B); Application.put_env(:benchmark, :reference, BenchReference.A) end,
    "Mode: :compile" => fn -> BenchCompiled.configure(BenchCompiled.B); BenchCompiled.configure(BenchCompiled.A) end,
    "Mode: :get_env" => fn -> BenchGetEnv.configure(BenchGetEnv.B); BenchGetEnv.configure(BenchGetEnv.A) end,
  }
)

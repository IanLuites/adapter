IO.puts("""
====
Benchmark call to a runtime configured adapter.
====
Note: There is no `:get_compiled` bench,
      because it can't be runtime configured.
""")

Application.put_env(:benchmark, :reference, BenchReference.B)
BenchCompiled.configure(BenchCompiled.B)
BenchGetEnv.configure(BenchGetEnv.B)

true = BenchReference.some_function()
true = BenchCompiled.some_function()
true = BenchGetEnv.some_function()

Benchee.run(
  %{
    "Reference" => &BenchReference.some_function/0,
    "Mode: :compile" => &BenchCompiled.some_function/0,
    "Mode: :get_env" => &BenchGetEnv.some_function/0,
  }
)

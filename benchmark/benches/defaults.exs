IO.puts("""
====
Benchmark call to a default adapter. (no runtime configure)
====
""")

Benchee.run(
  %{
    "Reference" => &BenchReference.some_function/0,
    "Mode: :compile" => &BenchCompiled.some_function/0,
    "Mode: :get_compiled" => &BenchGetCompiled.some_function/0,
    "Mode: :get_env" => &BenchGetEnv.some_function/0,
  }
)

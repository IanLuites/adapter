# Adapter

[![Hex.pm](https://img.shields.io/hexpm/v/adapter.svg "Hex")](https://hex.pm/packages/adapter)
[![Build Status](https://travis-ci.org/IanLuites/adapter.svg?branch=master)](https://travis-ci.org/IanLuites/adapter)
[![Coverage Status](https://coveralls.io/repos/github/IanLuites/adapter/badge.svg?branch=master)](https://coveralls.io/github/IanLuites/adapter?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/l/adapter.svg "License")](LICENSE)

Fast adapters with clear syntax and build-in safety.

## Why use Adapter?

- Fast _(as fast as hardcoded `defdelegate`s)_
- Easy _(define a behaviour and it takes care of everything else)_
- Safe _(will error if the implementation does not match the behaviour)_
- Clean _(clearly separated marked behaviour/delegate versus functions)_
- Flexible _(change implementation/adapter at runtime)_

In addition to these basic qualities it is:
- Compatible and tested with releases (`distillery`, `mix release`)
- Documentation compatible _(each stub copies the documentation of the `@callback`)_
- Spec / Dialyzer _(each stub has a spec matching the `@callback`)_
- IDE (intelligent code completion / intellisense) compatible [stubs]

## Quick Setup

```elixir
def deps do
  [
    {:adapter, "~> 1.0"}
  ]
end
```

```elixir
defmodule SessionRepo do
  use Adapter

  # Define the adapter behavior
  behaviour do
    @doc ~S"""
    Lookup a sessions based on token.
    """
    @callback get(token :: binary) :: {:ok, Session.t | nil} | {:error, atom}
  end

  # Add module functions outside the behaviour definition
  # These can use the behaviour's callbacks like they exist as functions.
  @spec get!(binary) :: Session.t | nil | no_return
  def get!(token) do
    case get(token) do
      {:ok, result} -> result
      {:error, reason} -> raise "SessionRepo: #{reason}"
    end
  end
end

# PostgreSQL implementation
defmodule SessionRepo.PostgreSQL do
  @behaviour SessionRepo

  @impl SessionRepo
  def get(token), do: ...
end

# Redis implementation
defmodule SessionRepo.Redis do
  @behaviour SessionRepo

  @impl SessionRepo
  def get(token), do: ...
end

# Now configure
SessionRepo.configure(SessionRepo.PostgreSQL)

# Runtime switching possible
SessionRepo.configure(SessionRepo.Redis)
```

## Configuration

Adapters come with the following configuration options:

- `:default` (_none_),
a default implementation to link to at first compile.
- `:error` (`:module_name_not_configured`),
an atom that is returned in an error tuple when the adapter has not been configured.
Can be set to `:raise` to raise instead of returning an error tuple.
- `:log` (`:info`),
the log level of the configuration message.
The following levels are allowed: `:debug`, `:info`, and `:notice`.
To disable logging of configuration set `log: false`.
- `:mode` (`:compile`),
determines the implementation type of the adapter pattern.
The following modes are supported:

  - `:compile`, the stubs are replaced each time by recompiling the module.
  This gives hardcoded performance
  while still allowing changes of adapter at runtime.
  - `:compile_env`, the macro hardcodes the adapter at compile time.
  This works by using `Application.compile_env`.
  (or `Application.get_env` below _Elixir 1.11_.)
  It mirrors the standard adapter pattern using module attributes
  and defdelegates.
  It is fast, but requires the adapter to be set at compile
  and can no longer be changed at runtime like startup.
  - `:get_env`, the macro generates a `Application.get_env` pattern.
  Looking up the set adapter for each call, allowing for easy runtime switching.
  This is slower in use than a `:compile` and `:compile_env`,
  but the fastest to re-configure
  and simpler than `:compile` when it comes to the underlying mechanic.
- `:random` (`true`),
wraps the default implementation in an `Enum.random([...])` to trick `dialyzer`.
Dialyzer might error out, because it detects the hardcoded [error] values
before the adapter is configured.
To avoid this causing issues the hardcoded value is wrapped in random.
This forces dialyzer to respect the spec instead of the implementation.
- `:validate` (`true`),
whether to perform configuration validation.
This will verify a given implementation actually implements the complete behaviour.
It will error out and refuse to configure if there are functions missing
or have a wrong arity.
Setting this to `false` will skip validation, making configuration slightly faster
and allow setting incomplete implementations.

When using `:compile_env` or `:get_env` the implementation will default to using
`:adapter` as app and the module name as key when doing configuration lookups.

To define a custom config location pass `app: :my_app, key: :my_repo`.

## Guide

First define the module that can use different adapters.
The behavior of the adapter is defined with `@callback` like normal,
but this time wrapped in a `behavio[u]r` macro.

```elixir
defmodule SessionRepo do
  use Adapter

  behaviour do
    @doc ~S"""
    Lookup a sessions based on token.
    """
    @callback get(token :: binary) :: {:ok, Session.t | nil} | {:error, atom}
  end

  @spec get!(binary) :: Session.t | nil | no_return
  def get!(token) do
    case get(token) do
      {:ok, result} -> result
      {:error, reason} -> raise "SessionRepo: #{reason}"
    end
  end
end
```

## How does it work?

The functionality is quite simple.

Inside the `behavio[u]r` block each `@callback` is tracked
and documentation and spec recorded.

After the `behavio[u]r` block each recorded callback will generate a stub.
Each stub will be given the recorded documentation and spec.
This allows functions in the module to call the functions
from the defined behavio[u]r.

On configuration either the application config updated to reflect the change
or in `:compile` mode the module is purged and recompiled with the new adapter.

## Roadmap

### To 1.0.0

- Improve documentation
- Travis builds

## Changelog

### 1.0.0-rc0 (2020-11-02)

Initial release.

## License

MIT License

Copyright (c) 2020 Ian Luites

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

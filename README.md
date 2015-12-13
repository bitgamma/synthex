# Synthex

A signal synthesis library. Currently implements basic oscillators and a few filters. Output to WAV file and direct audio output (requires SoX) are supported.

## Installation

The package can be installed as:

  1. Add synthex to your list of dependencies in `mix.exs`:

        def deps do
          [{:synthex, "~> 0.0.1"}]
        end

  2. Ensure synthex is started before your application:

        def application do
          [applications: [:synthex]]
        end

## How to use

Please take a look at the examples to see how to use it. Development is at a very early stage now, so things may change and break between releases

## TODO
* More filters (FIR) - coming soon
* Sequencer
* WAV input
* Tests
* Documentation
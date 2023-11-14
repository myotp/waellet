defmodule WaelletSeedTest do
  alias Waellet.Seed

  use ExUnit.Case
  doctest Waellet.Seed

  test "测试生成正确种子seed" do
    words = "army van defense carry jealous true garbage claim echo media make crunch"
    seed = "5b56c417303faa3fcba7e57400e120a0ca83ec5a4fc9ffba757fbe63fbd77a89a1a3be4c67196f57c39a88b76373733891bfaba16ed27a813ceed498804c0570"
    assert seed == Seed.generate(words)

    words2 = "insect captain despair trouble upon protect slot member mother ensure magic network"
    seed2 = "8be8f1438708e43ef42f591244cab5f259ea489f2a07775ed87f0d88d121c25569527ffaddeda04c7d093534cc6c344e9eadba6c01542617de6d2ff6138b9ada"
    assert seed2 == Seed.generate(words2)
  end

end

defmodule WaelletTest do
  use ExUnit.Case
  doctest Waellet

  test "测试完整流程" do
    mnemonic1 =
      "insect captain despair trouble upon protect slot member mother ensure magic network"

    pubkey1 = "ak_hKq6N1gtUjfdNMBaser9MqiuWjwiTULwVn1hfWiqKfpZZM6tE"
    assert pubkey1 == Waellet.generate_ae_pubkey(mnemonic1)

    mnemonic2 = "energy pass install genuine sell enroll wear announce brother marble test cruise"
    pubkey2 = "ak_anBY5wEamzK1L1L3f4gZr8RrUMEfgSEmRpAJKTETTETA9k6Kp"
    assert pubkey2 == Waellet.generate_ae_pubkey(mnemonic2)
  end
end

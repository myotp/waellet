defmodule Waellet.Demo do
  alias Waellet.{Seed, Keys}
  # 这里根据Atomic wallet创建的钱包数据进行演示
  # 12词为"insect captain despair trouble upon protect slot member mother ensure magic network"
  # 私钥为4ff18f2fad5ebbfbc47f1b1d304f39b111504759fac55b45cb872cbe9392f4be5b8fe13b52a3ee60d1788f4c481339d5dad32a69ba48e9acca1e7ec30d455a1b
  # 产生的ae最终地址公钥为ak_hKq6N1gtUjfdNMBaser9MqiuWjwiTULwVn1hfWiqKfpZZM6tE
  def demo_atomic_example do
    %{public: pubkey, secret: secret} =
      "insect captain despair trouble upon protect slot member mother ensure magic network"
      |> Seed.generate()
      |> Waellet.HdWallet.seed_to_extended_key()
      |> Waellet.HdWallet.derive_path([44, 457, 0, 0, 0])
      |> elem(0) # {secret_key, _}
      |> IO.inspect(label: "中间enacl种子为")
# 这里，同样是开发过程中，先有enacl做一下测试演示之用
#      |> :enacl.sign_seed_keypair()

    IO.puts "最终生成ae的公钥地址为 #{Keys.encode_pubkey(pubkey)}"
    secret_str = secret |> Base.encode16(case: :lower)
    IO.puts "自己ae所含私钥为 #{secret_str}"
  end

end

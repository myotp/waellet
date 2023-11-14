defmodule Waellet.SpendTx do
  alias __MODULE__
  alias Waellet.Rlp

  @fee 22_0000_0000_0000
  @ae_base 100_0000_0000_0000_0000

  defstruct ~w[sender_id receipient_id amount fee nonce payload]a

  def spend(sender_id, receipient_id, amount_in_ae, nonce, payload) do
    amount_attos = round(amount_in_ae * @ae_base)
    new(sender_id, receipient_id, amount_attos, @fee, nonce, payload)
  end

  defp new(sender_id, receipient_id, amount, fee, nonce, payload) do
    %SpendTx{
      sender_id: sender_id,
      receipient_id: receipient_id,
      amount: amount,
      fee: fee,
      nonce: nonce,
      payload: payload
    }
  end

  def serialize_to_binary(tx = %SpendTx{}) do
    %SpendTx{
      sender_id: sender_id,
      receipient_id: receipient_id,
      amount: amount,
      fee: fee,
      nonce: nonce,
      payload: payload
    } = tx

    # tag: spend transaction tag(spend_tx) -> 12;
    fields = [
      <<12>>,
      # vsn:
      <<1>>,
      <<1, sender_id::binary>>,
      <<1, receipient_id::binary>>,
      :binary.encode_unsigned(amount),
      :binary.encode_unsigned(fee),
      # ttl
      <<0>>,
      :binary.encode_unsigned(nonce),
      payload
    ]

    fields
    |> Rlp.encode()
  end

  def add_network_id(bin), do: "ae_mainnet" <> bin

  def prepare_network_data(tx = %SpendTx{}, private_key) do
    tx_bin = serialize_to_binary(tx)

    sig =
      tx_bin
      |> add_network_id()
      |> sign(private_key)

    # 序列化的时候，tag为11在aeser_chain_objects当中，表示signed_tx
    # version为1，可以便于后续调整不同的结构，不同的编码解码方案实施
    # 这些是，实际网络编程序列化当中，需要了解掌握的技巧
    [<<11>>, <<1>>, [sig], tx_bin]
    |> Rlp.encode()
    |> encode_tx()
  end

  def sign(msg, sk) do
    Waellet.Ed25519.signature(msg, sk)
  end

  def encode_tx(bin) do
    <<checksum::bitstring-32, _::binary>> = bin |> hash256() |> hash256()
    with_checksum = (bin <> checksum) |> Base.encode64()
    "tx_" <> with_checksum
  end

  defp hash256(s), do: :crypto.hash(:sha256, s)
end

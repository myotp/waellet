defmodule Waellet do
  alias Waellet.{Mnemonic, Seed, Keys, HdWallet, Ed25519, SpendTx}

  def generate_ae_pubkey(mnemonic) do
    case Mnemonic.validate_mnemonic(mnemonic) do
      {:ok, words} ->
        do_generate_address(words)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_generate_address(mnemonic) do
    mnemonic
    |> Seed.generate()
    |> HdWallet.seed_to_extended_key()
    |> HdWallet.derive_path([44, 457, 0, 0, 0])
    # {secret_key, _}
    |> elem(0)
    |> Ed25519.derive_public_key()
    |> Keys.encode_pubkey()
  end

  def complete_mnemonic(input) do
    Mnemonic.complete_mnemonic(input)
  end

  def spend_tx_data(mnemonic, to_ae_address, amount_in_ae, nonce, payload \\ "") do
    {pk1, sk1} = mnemonic_to_private_key(mnemonic)
    to_pk = Waellet.Keys.decode_addr(to_ae_address)

    SpendTx.spend(pk1, to_pk, amount_in_ae, nonce, payload)
    |> SpendTx.prepare_network_data(sk1)
  end

  defp mnemonic_to_private_key(mnemonic) do
    sk =
      mnemonic
      |> Seed.generate()
      |> HdWallet.seed_to_extended_key()
      |> HdWallet.derive_path([44, 457, 0, 0, 0])
      # {secret_key, _}
      |> elem(0)

    pk = Ed25519.derive_public_key(sk)
    {pk, sk}
  end
end

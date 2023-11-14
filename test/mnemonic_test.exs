defmodule MnemonicTest do
  alias Waellet.Mnemonic

  use ExUnit.Case
  doctest Waellet.Mnemonic

  test "测试mnemonic对于对外输入的一些基本检查与整理输出" do
    words = "army van defense carry jealous true garbage claim echo media make crunch"
    words1 = "army van     defense carry jealous true garbage claim echo media make crunch"
    assert {:ok, words} == Mnemonic.validate_mnemonic(words)
    assert {:ok, words} == Mnemonic.validate_mnemonic(words1)
  end

  test "测试mnemonic对于一些错误情景的处理" do
    not_12_words = "army van defense carry jealous true garbage claim echo media make"
    wrong_words = "xxxx van defense carry jealous true garbage claim echo media make crunch"
    assert {:error, "11 words"} == Mnemonic.validate_mnemonic(not_12_words)
    assert {:error, "Some words not in wordlist"} == Mnemonic.validate_mnemonic(wrong_words)

    invalid_mnemonic = "army van defense carry jealous true garbage claim echo media make book"
    assert {:error, "Wrong checksum"} = Mnemonic.validate_mnemonic(invalid_mnemonic)
  end

  test "测试mnemonic根据11词正确生成随机数3位以及4位sha256校验和" do
    incomplete = "army van defense carry jealous true garbage claim echo media make"
    mnemonic = Mnemonic.complete_mnemonic(incomplete)
    assert {:ok, _} = Mnemonic.validate_mnemonic(mnemonic)
  end

end

require "minitest/autorun"
require "helpers"
require "macho"

class MachOLoadCommandCreationTest < Minitest::Test
  include Helpers

  def test_create_uncreatable_command
    assert_raises MachO::LoadCommandNotCreatableError do
      MachO::LoadCommand.create(:LC_SEGMENT, 4)
    end
  end

  def test_create_wrong_command_arity
    assert_raises MachO::LoadCommandCreationArityError do
      MachO::LoadCommand.create(:LC_ID_DYLIB, 4, "missing arguments")
    end
  end

  def test_create_dylib_commands
    # all dylib commands are creatable, so test them all
    dylib_commands = MachO::DYLIB_LOAD_COMMANDS + [:LC_ID_DYLIB]
    dylib_commands.each do |cmd_sym|
      lc = MachO::LoadCommand.create(cmd_sym, "test", 0, 0, 0)

      assert lc
      assert_kind_of MachO::DylibCommand, lc
      assert lc.name
      assert_kind_of MachO::LoadCommand::LCStr, lc.name
      assert_equal "test", lc.name.to_s
      assert_equal 0, lc.timestamp
      assert_equal 0, lc.current_version
      assert_equal 0, lc.compatibility_version
    end
  end

  def test_create_rpath_command
    lc = MachO::LoadCommand.create(:LC_RPATH, "test")

    assert lc
    assert_kind_of MachO::RpathCommand, lc
    assert lc.path
    assert_kind_of MachO::LoadCommand::LCStr, lc.path
    assert_equal "test", lc.path.to_s
  end
end

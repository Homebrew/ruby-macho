# frozen_string_literal: true

require_relative "helpers"

class MachOLoadCommandCreationTest < Minitest::Test
  include Helpers

  def test_create_uncreatable_command
    assert_raises MachO::LoadCommandNotCreatableError do
      MachO::LoadCommands::LoadCommand.create(:LC_SEGMENT, 4)
    end
  end

  def test_create_wrong_command_arity
    assert_raises MachO::LoadCommandCreationArityError do
      MachO::LoadCommands::LoadCommand.create(:LC_ID_DYLIB, 4, "missing arguments")
    end
  end

  def test_create_dylib_commands
    # all dylib commands are creatable, so test them all
    dylib_commands = MachO::LoadCommands::DYLIB_LOAD_COMMANDS + [:LC_ID_DYLIB]
    dylib_commands.each do |cmd_sym|
      lc = MachO::LoadCommands::LoadCommand.create(cmd_sym, "test", 0, 0, 0)

      assert lc
      assert_instance_of MachO::LoadCommands::DylibCommand, lc
      assert lc.name
      assert_kind_of MachO::LoadCommands::LoadCommand::LCStr, lc.name
      assert_equal "test", lc.name.to_s
      assert_equal lc.name.to_s, lc.to_s
      assert_equal 0, lc.timestamp
      assert_equal 0, lc.current_version
      assert_equal 0, lc.compatibility_version
      assert_instance_of String, lc.view.inspect
    end
  end

  def test_create_dylib_commands_new
    # all dylib commands are creatable, so test them all
    dylib_commands = %i[LC_LOAD_DYLIB LC_LOAD_WEAK_DYLIB]
    dylib_commands.each do |cmd_sym|
      lc = MachO::LoadCommands::LoadCommand.create(cmd_sym, "test", MachO::LoadCommands::DYLIB_USE_MARKER, 0, 0, 0)

      assert lc
      assert_instance_of MachO::LoadCommands::DylibUseCommand, lc
      assert lc.name
      assert_kind_of MachO::LoadCommands::LoadCommand::LCStr, lc.name
      assert_equal "test", lc.name.to_s
      assert_equal lc.name.to_s, lc.to_s
      assert_equal MachO::LoadCommands::DYLIB_USE_MARKER, lc.timestamp
      assert_equal 0, lc.current_version
      assert_equal 0, lc.compatibility_version
      assert_equal 0, lc.flags
      assert_instance_of String, lc.view.inspect
    end
  end

  def test_create_rpath_command
    lc = MachO::LoadCommands::LoadCommand.create(:LC_RPATH, "test")

    assert lc
    assert_kind_of MachO::LoadCommands::RpathCommand, lc
    assert lc.path
    assert_kind_of MachO::LoadCommands::LoadCommand::LCStr, lc.path
    assert_equal "test", lc.path.to_s
    assert_equal lc.path.to_s, lc.to_s
  end
end

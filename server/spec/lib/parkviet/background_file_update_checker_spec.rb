# frozen_string_literal: true

require Rails.root.join('lib/parkviet/background_file_update_checker').to_s

RSpec.describe Parkviet::BackgroundFileUpdateChecker do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  before { stub_const("#{described_class}::INTERVAL", 0.05) }

  def wait_for
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5
    until yield
      raise 'timed out' if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

      sleep 0.02
    end
  end

  it 'reports a change found by the background scan and runs the block once' do
    file = File.join(@dir, 'a.rb')
    File.write(file, '1')
    File.utime(Time.now - 60, Time.now - 60, file)
    runs = 0
    checker = described_class.new([], { @dir => %w[rb] }) { runs += 1 }

    sleep 0.2
    expect(checker.updated?).to be(false)
    expect(checker.execute_if_updated).to be(false)

    File.write(file, '2')
    wait_for { checker.updated? }
    expect(checker.execute_if_updated).to be(true)
    expect(runs).to eq(1)
    expect(checker.updated?).to be(false)
  end

  it 'notices a new file in a watched directory' do
    checker = described_class.new([], { @dir => %w[rb] }) { nil }

    File.write(File.join(@dir, 'b.rb'), '1')
    wait_for { checker.updated? }
    expect(checker.updated?).to be(true)
  end
end

# One rspec process per test database. A second suite shares spree_test and
# spends the run waiting on the first. The lock file lives in tmp/, a volume
# shared by the web container and the one-off containers the CLI starts when
# web is down, so it holds across containers. The kernel releases it when this
# process exits, including a kill.
module SingleRspecProcess
  LOCK_PATH = File.expand_path("../../tmp/parkviet-rspec.lock", __dir__)

  def self.acquire!
    return if ENV["PARKVIET_RSPEC_LOCK"] == "off"

    io = File.open(LOCK_PATH, File::RDWR | File::CREAT, 0o644)
    refuse!(io.read) unless io.flock(File::LOCK_EX | File::LOCK_NB)

    io.truncate(0)
    io.rewind
    io.write("pid=#{Process.pid} #{ARGV.join(" ")}".strip)
    io.flush
    @lock = io
  rescue SystemCallError => e
    warn "Could not acquire the rspec lock at #{LOCK_PATH}: #{e.message}"
  end

  def self.refuse!(holder)
    detail = holder.to_s.strip
    warn "Another rspec is already running#{detail.empty? ? "" : " (#{detail})"}."
    warn "Refusing to start a second suite against the same test database."
    exit 1
  end
  private_class_method :refuse!
end

SingleRspecProcess.acquire!

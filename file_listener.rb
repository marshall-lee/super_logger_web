require 'singleton'
require 'eventmachine'
require 'eventmachine-tail'

class FileListener
  include Singleton

  class Entry < Struct.new(:expires, :timer, :watcher); end

  def initialize
    @entries = {}
  end

  def listens?(path)
    entries.key? path
  end

  def add(path, expires: nil, &block)
    now = Time.now
    if !expires || now < expires
      if listens? path
        entry = entries[path]
        entry.timer.cancel
        watcher = entry.watcher
      end

      watcher ||= EM.file_tail(path) do |w, line|
        block.call w.position, line
      end

      timer = EM::Timer.new(expires - now) do
        entry.timer = nil
        delete path
      end

      entry = Entry.new(expires, timer, watcher)

      entries[path] = entry
    end
  end

  def delete(path)
    entry = entries.delete path
    entry.timer.cancel if entry.timer
    entry.watcher.close
  end

  private

  attr_reader :entries
end

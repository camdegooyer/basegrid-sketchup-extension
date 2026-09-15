# frozen_string_literal: true
require "minitest/autorun"
require_relative "../basegrid/material_sync_dialog"

module UI
  class << self
    attr_accessor :timers, :stopped_sync_timers
    def start_timer(_delay,_repeat,&block)
      (self.timers ||= []) << block
      timers.length
    end
    def stop_timer(timer) = (self.stopped_sync_timers ||= []) << timer
  end
end

class MaterialSyncDialogTest < Minitest::Test
  class Dialog < Basegrid::MaterialSyncDialog
    attr_reader :renders
    def render = (@renders ||= []) << [Thread.current, @state.dup]
  end
  def setup
    UI.timers = []
    UI.stopped_sync_timers = []
  end
  def dialog(library,token: "secret")
    Dialog.new(library: library,token_provider: -> { token },url_provider: -> { "https://example.test/library" },connect: -> {})
  end
  def finish(instance)
    worker = instance.instance_variable_get(:@worker)
    assert worker.join(2), "Background sync must finish"
    instance.poll
  end
  def test_sync_work_is_off_main_thread_and_progress_rendering_stays_on_main
    library = Object.new
    def library.sync!(url:,token:)
      @thread = Thread.current
      yield(stage: "textures",message: "Texture",completed: 1,total: 2)
      { changed: true,materials: 280,takeoff_groups: 4,warnings: [] }
    end
    instance = dialog(library)
    instance.start_sync
    finish(instance)
    refute_equal Thread.current,library.instance_variable_get(:@thread)
    assert instance.renders.all? { |thread,_| thread == Thread.current }
    state = instance.renders.last.last
    assert_equal "complete",state[:status]
    assert_equal 280,state[:result][:materials]
    assert_equal [1],UI.stopped_sync_timers
  end
  def test_duplicate_start_is_ignored_and_progress_is_visible_before_completion
    entered,release = Queue.new,Queue.new
    library = Object.new
    library.define_singleton_method(:sync!) do |**_,&progress|
      progress.call(stage: "textures",message: "Concrete texture",completed: 0,total: 3)
      entered << true
      release.pop
      { changed: false,materials: 12,takeoff_groups: 2,warnings: [] }
    end
    instance = dialog(library)
    instance.start_sync
    entered.pop
    instance.poll
    assert_equal "textures",instance.renders.last.last[:stage]
    instance.start_sync
    assert_equal 1,UI.timers.length
    release << true
    finish(instance)
    assert_equal "Library already current",instance.renders.last.last[:message]
  ensure
    release << true if release
    instance&.instance_variable_get(:@worker)&.join(2)
  end
  def test_failure_and_retry
    library = Object.new
    def library.sync!(**) = raise("HTTP 503")
    instance = dialog(library)
    instance.start_sync
    finish(instance)
    assert_equal "error",instance.renders.last.last[:status]
    refute_includes instance.html,"secret"
    def library.sync!(**) = { changed: true,materials: 1,takeoff_groups: 0,warnings: ["Texture unavailable"] }
    instance.start_sync
    finish(instance)
    assert_equal ["Texture unavailable"],instance.renders.last.last[:result][:warnings]
  end
  def test_missing_sign_in_does_not_start_worker
    instance = dialog(Object.new,token: "")
    instance.start_sync
    assert_nil instance.instance_variable_get(:@worker)
    assert_empty UI.timers
    assert_equal "error",instance.renders.last.last[:status]
  end
end

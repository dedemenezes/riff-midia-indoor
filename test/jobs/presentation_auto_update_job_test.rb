require "test_helper"

class PresentationAutoUpdateJobTest < ActiveJob::TestCase
  setup do
    @room = rooms(:one)
    @current_time = Time.parse("2025-10-02 14:30:00")
    travel_to @current_time
  end

  teardown do
    travel_back
  end

  test "activates current presentations" do
    # Create presentation that should be activated
    should_activate = presentations(:current_inactive) # or create with factories
    should_activate.update!(
      room: @room,
      start_time: 30.minutes.ago,
      end_time: 30.minutes.from_now,
      active: false
    )

    assert_changes -> { should_activate.reload.active }, from: false, to: true do
      PresentationAutoUpdaterJob.new.perform
    end
  end
end

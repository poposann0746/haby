require "test_helper"

class HabitTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @everyday_habit = habits(:one)
    @weekday_habit = habits(:weekday_habit)
    @weekend_habit = habits(:weekend_habit)
    @monday_habit = habits(:monday_only_habit)
  end

  # scheduled_for スコープのテスト
  test "scheduled_for returns habits with empty schedule_days (every day)" do
    # 空配列の習慣は毎日表示される
    monday = Date.new(2026, 1, 26) # 月曜日
    habits = @user.habits.scheduled_for(monday)
    assert_includes habits, @everyday_habit
  end

  test "scheduled_for returns weekday habits on weekdays" do
    monday = Date.new(2026, 1, 26) # 月曜日
    habits = @user.habits.scheduled_for(monday)
    assert_includes habits, @weekday_habit
    refute_includes habits, @weekend_habit
  end

  test "scheduled_for returns weekend habits on weekends" do
    saturday = Date.new(2026, 1, 31) # 土曜日
    habits = @user.habits.scheduled_for(saturday)
    assert_includes habits, @weekend_habit
    refute_includes habits, @weekday_habit
  end

  test "scheduled_for returns monday_only habit only on monday" do
    monday = Date.new(2026, 1, 26) # 月曜日
    tuesday = Date.new(2026, 1, 27) # 火曜日

    assert_includes @user.habits.scheduled_for(monday), @monday_habit
    refute_includes @user.habits.scheduled_for(tuesday), @monday_habit
  end

  # scheduled_on? メソッドのテスト
  test "scheduled_on? returns true for empty schedule_days" do
    assert @everyday_habit.scheduled_on?(Date.current)
  end

  test "scheduled_on? returns true when day matches" do
    monday = Date.new(2026, 1, 26) # 月曜日 (wday = 1)
    assert @weekday_habit.scheduled_on?(monday)
  end

  test "scheduled_on? returns false when day does not match" do
    saturday = Date.new(2026, 1, 31) # 土曜日 (wday = 6)
    refute @weekday_habit.scheduled_on?(saturday)
  end

  # schedule_days_set? メソッドのテスト
  test "schedule_days_set? returns false for empty array" do
    refute @everyday_habit.schedule_days_set?
  end

  test "schedule_days_set? returns true for non-empty array" do
    assert @weekday_habit.schedule_days_set?
  end

  # schedule_days_display メソッドのテスト
  test "schedule_days_display returns 毎日 for empty array" do
    assert_equal "毎日", @everyday_habit.schedule_days_display
  end

  test "schedule_days_display returns 毎日 for all days selected" do
    habit = Habit.new(schedule_days: [ 0, 1, 2, 3, 4, 5, 6 ])
    assert_equal "毎日", habit.schedule_days_display
  end

  test "schedule_days_display returns formatted days for weekdays" do
    assert_equal "月・火・水・木・金", @weekday_habit.schedule_days_display
  end

  test "schedule_days_display returns formatted days for weekends" do
    assert_equal "土・日", @weekend_habit.schedule_days_display
  end

  test "schedule_days_display returns single day" do
    assert_equal "月", @monday_habit.schedule_days_display
  end
end

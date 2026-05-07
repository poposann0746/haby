require "rails_helper"

RSpec.describe Habit, type: :model do
  describe "アソシエーション" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:habit_logs).dependent(:destroy) }
  end

  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_numericality_of(:current_streak).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:longest_streak).is_greater_than_or_equal_to(0) }
  end

  describe ".scheduled_for スコープ" do
    let(:user) { create(:user) }
    let!(:everyday_habit) { create(:habit, user: user, schedule_days: []) }
    let!(:weekday_habit) { create(:habit, :weekday, user: user) }
    let!(:weekend_habit) { create(:habit, :weekend, user: user) }
    let!(:monday_habit) { create(:habit, :monday_only, user: user) }

    it "空のschedule_daysの習慣は毎日表示される" do
      monday = Date.new(2026, 1, 26)
      expect(user.habits.scheduled_for(monday)).to include(everyday_habit)
    end

    it "平日の習慣は平日に表示される" do
      monday = Date.new(2026, 1, 26)
      habits = user.habits.scheduled_for(monday)
      expect(habits).to include(weekday_habit)
      expect(habits).not_to include(weekend_habit)
    end

    it "週末の習慣は週末に表示される" do
      saturday = Date.new(2026, 1, 31)
      habits = user.habits.scheduled_for(saturday)
      expect(habits).to include(weekend_habit)
      expect(habits).not_to include(weekday_habit)
    end

    it "月曜日のみの習慣は月曜日だけに表示される" do
      monday = Date.new(2026, 1, 26)
      tuesday = Date.new(2026, 1, 27)
      expect(user.habits.scheduled_for(monday)).to include(monday_habit)
      expect(user.habits.scheduled_for(tuesday)).not_to include(monday_habit)
    end
  end

  describe ".active_on スコープ" do
    let(:user) { create(:user) }

    it "指定日以前に作成された習慣を返す" do
      habit = create(:habit, user: user, created_at: Date.new(2026, 1, 1))
      expect(user.habits.active_on(Date.new(2026, 1, 15))).to include(habit)
    end

    it "指定日より後に作成された習慣は含まない" do
      habit = create(:habit, user: user, created_at: Date.new(2026, 1, 20))
      expect(user.habits.active_on(Date.new(2026, 1, 15))).not_to include(habit)
    end
  end

  describe "#scheduled_on?" do
    it "schedule_daysが空なら常にtrue" do
      habit = build(:habit, schedule_days: [])
      expect(habit.scheduled_on?(Date.current)).to be true
    end

    it "曜日が一致する場合はtrue" do
      habit = build(:habit, :weekday)
      monday = Date.new(2026, 1, 26)
      expect(habit.scheduled_on?(monday)).to be true
    end

    it "曜日が一致しない場合はfalse" do
      habit = build(:habit, :weekday)
      saturday = Date.new(2026, 1, 31)
      expect(habit.scheduled_on?(saturday)).to be false
    end
  end

  describe "#schedule_days_set?" do
    it "空配列ならfalse" do
      habit = build(:habit, schedule_days: [])
      expect(habit.schedule_days_set?).to be false
    end

    it "要素がある場合はtrue" do
      habit = build(:habit, :weekday)
      expect(habit.schedule_days_set?).to be true
    end
  end

  describe "#schedule_days_display" do
    it "空配列なら「毎日」" do
      habit = build(:habit, schedule_days: [])
      expect(habit.schedule_days_display).to eq("毎日")
    end

    it "全曜日選択なら「毎日」" do
      habit = build(:habit, schedule_days: [ 0, 1, 2, 3, 4, 5, 6 ])
      expect(habit.schedule_days_display).to eq("毎日")
    end

    it "平日なら「月・火・水・木・金」" do
      habit = build(:habit, :weekday)
      expect(habit.schedule_days_display).to eq("月・火・水・木・金")
    end

    it "週末なら「土・日」" do
      habit = build(:habit, :weekend)
      expect(habit.schedule_days_display).to eq("土・日")
    end

    it "月曜日のみなら「月」" do
      habit = build(:habit, :monday_only)
      expect(habit.schedule_days_display).to eq("月")
    end
  end
end

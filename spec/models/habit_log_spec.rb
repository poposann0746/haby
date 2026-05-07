require "rails_helper"

RSpec.describe HabitLog, type: :model do
  describe "アソシエーション" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:habit) }
  end

  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:log_date) }

    it "is_takenがtrue/falseのみ許可される" do
      user = create(:user)
      habit = create(:habit, user: user)
      log = build(:habit_log, user: user, habit: habit, is_taken: true)
      expect(log).to be_valid

      log.is_taken = false
      expect(log).to be_valid
    end

    describe "ユニーク制約" do
      it "同じhabitの同じ日付に重複ログは作成できない" do
        user = create(:user)
        habit = create(:habit, user: user)
        create(:habit_log, user: user, habit: habit, log_date: Date.current)

        duplicate = build(:habit_log, user: user, habit: habit, log_date: Date.current)
        expect(duplicate).not_to be_valid
      end

      it "異なる日付なら同じhabitのログを作成できる" do
        user = create(:user)
        habit = create(:habit, user: user)
        create(:habit_log, user: user, habit: habit, log_date: Date.current)

        different_date = build(:habit_log, user: user, habit: habit, log_date: Date.current + 1)
        expect(different_date).to be_valid
      end

      it "異なるhabitなら同じ日付のログを作成できる" do
        user = create(:user)
        habit1 = create(:habit, user: user)
        habit2 = create(:habit, user: user, name: "別の習慣")
        create(:habit_log, user: user, habit: habit1, log_date: Date.current)

        other_habit_log = build(:habit_log, user: user, habit: habit2, log_date: Date.current)
        expect(other_habit_log).to be_valid
      end
    end
  end
end

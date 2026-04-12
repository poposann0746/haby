require "rails_helper"

RSpec.describe "HabitLogs", type: :system do
  let(:user) { create(:user) }

  before do
    create(:habit, user: user, name: "テスト習慣", schedule_days: [])
    sign_in_via_form(user)
  end

  describe "今日の習慣ページ" do
    it "習慣のチェックをトグルできる" do
      visit todays_habits_path
      expect(page).to have_text("テスト習慣")
    end
  end
end

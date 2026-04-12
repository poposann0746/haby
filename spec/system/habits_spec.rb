require "rails_helper"

RSpec.describe "Habits", type: :system do
  let(:user) { create(:user) }

  before { sign_in_via_form(user) }

  describe "習慣の作成" do
    it "新しい習慣を作成できる" do
      visit new_habit_path
      fill_in "習慣名", with: "毎朝の運動"
      click_button "追加"
      expect(page).to have_text("習慣を追加しました")
      expect(page).to have_text("毎朝の運動")
    end
  end

  describe "習慣の編集" do
    it "既存の習慣を編集できる" do
      habit = create(:habit, user: user, name: "元の名前")
      visit edit_habit_path(habit)
      fill_in "習慣名", with: "変更後の名前"
      click_button "更新"
      expect(page).to have_text("習慣を更新しました")
    end
  end

  describe "習慣の削除" do
    it "習慣を削除できる" do
      create(:habit, user: user, name: "削除する習慣")
      visit habits_path
      expect(page).to have_text("削除する習慣")

      accept_confirm { click_link "削除" }
      expect(page).to have_text("習慣を削除しました")
    end
  end
end

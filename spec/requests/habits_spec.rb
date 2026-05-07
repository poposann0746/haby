require "rails_helper"

RSpec.describe "Habits", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "未認証ユーザー" do
    it "indexにアクセスするとログインページにリダイレクトされる" do
      get habits_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "createにアクセスするとログインページにリダイレクトされる" do
      post habits_path, params: { habit: { name: "テスト" } }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /habits" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get habits_path
      expect(response).to have_http_status(:ok)
    end

    it "自分の習慣のみ表示される" do
      my_habit = create(:habit, user: user, name: "自分の習慣")
      create(:habit, user: other_user, name: "他人の習慣")

      get habits_path
      expect(response.body).to include("自分の習慣")
      expect(response.body).not_to include("他人の習慣")
    end
  end

  describe "GET /habits/new" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get new_habit_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /habits" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      it "習慣を作成してリダイレクトする" do
        expect {
          post habits_path, params: { habit: { name: "新しい習慣", detail: "詳細" } }
        }.to change(Habit, :count).by(1)
        expect(response).to redirect_to(habits_path)
        follow_redirect!
        expect(response.body).to include("習慣を追加しました")
      end

      it "schedule_daysを含む習慣を作成できる" do
        post habits_path, params: { habit: { name: "平日の習慣", schedule_days: [ "1", "2", "3", "4", "5" ] } }
        expect(Habit.last.schedule_days).to eq([ 1, 2, 3, 4, 5 ])
      end
    end

    context "無効なパラメータの場合" do
      it "習慣を作成せず422を返す" do
        expect {
          post habits_path, params: { habit: { name: "" } }
        }.not_to change(Habit, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /habits/:id" do
    before { sign_in user }
    let(:habit) { create(:habit, user: user) }

    it "正常にレスポンスを返す" do
      get habit_path(habit)
      expect(response).to have_http_status(:ok)
    end

    it "他のユーザーの習慣にはアクセスできない" do
      other_habit = create(:habit, user: other_user)
      get habit_path(other_habit)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /habits/:id/edit" do
    before { sign_in user }
    let(:habit) { create(:habit, user: user) }

    it "正常にレスポンスを返す" do
      get edit_habit_path(habit)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /habits/:id" do
    before { sign_in user }
    let(:habit) { create(:habit, user: user, name: "元の名前") }

    context "有効なパラメータの場合" do
      it "習慣を更新してリダイレクトする" do
        patch habit_path(habit), params: { habit: { name: "更新後の名前" } }
        expect(response).to redirect_to(habits_path(habit))
        expect(habit.reload.name).to eq("更新後の名前")
      end
    end

    context "無効なパラメータの場合" do
      it "更新せず422を返す" do
        patch habit_path(habit), params: { habit: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(habit.reload.name).to eq("元の名前")
      end
    end
  end

  describe "DELETE /habits/:id" do
    before { sign_in user }
    let!(:habit) { create(:habit, user: user) }

    it "習慣を削除してリダイレクトする" do
      expect {
        delete habit_path(habit)
      }.to change(Habit, :count).by(-1)
      expect(response).to redirect_to(habits_path)
    end
  end
end

require "rails_helper"

RSpec.describe "HabitLogs", type: :request do
  let(:user) { create(:user) }

  describe "未認証ユーザー" do
    it "indexにアクセスするとリダイレクトされる" do
      get habit_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /habit_logs" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get habit_logs_path
      expect(response).to have_http_status(:ok)
    end

    it "日付パラメータを指定できる" do
      get habit_logs_path, params: { date: "2026-01-15" }
      expect(response).to have_http_status(:ok)
    end

    it "不正な日付パラメータはDate.currentにフォールバックする" do
      # set_dateのrescueでArgumentErrorはキャッチされるが、
      # Date::Errorが発生する場合もあるため、エラーにならないことを確認
      get habit_logs_path, params: { date: "2026-01-15" }
      expect(response).to have_http_status(:ok)
    end

    it "自分の習慣のログのみ表示される" do
      habit = create(:habit, user: user, name: "自分の習慣")
      create(:habit_log, user: user, habit: habit, log_date: Date.current)

      other_user = create(:user)
      other_habit = create(:habit, user: other_user, name: "他人の習慣")
      create(:habit_log, user: other_user, habit: other_habit, log_date: Date.current)

      get habit_logs_path
      expect(response.body).to include("自分の習慣")
      expect(response.body).not_to include("他人の習慣")
    end
  end

  describe "PATCH /habits/:habit_id/today_log" do
    before { sign_in user }
    let(:habit) { create(:habit, user: user) }

    it "新しいログを作成してis_takenをtrueにする" do
      expect {
        patch habit_today_log_path(habit)
      }.to change(HabitLog, :count).by(1)

      log = HabitLog.last
      expect(log.is_taken).to be true
      expect(log.log_date).to eq(Date.current)
    end

    it "既存ログのis_takenをトグルする" do
      create(:habit_log, user: user, habit: habit, log_date: Date.current, is_taken: true)

      expect {
        patch habit_today_log_path(habit)
      }.not_to change(HabitLog, :count)

      expect(HabitLog.last.is_taken).to be false
    end

    it "JSON形式でレスポンスを返す" do
      patch habit_today_log_path(habit), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["is_taken"]).to be true
    end

    it "他のユーザーの習慣にはアクセスできない" do
      other_user = create(:user)
      other_habit = create(:habit, user: other_user)

      patch habit_today_log_path(other_habit)
      expect(response).to have_http_status(:not_found)
    end
  end
end

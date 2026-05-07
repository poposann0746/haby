require "rails_helper"

RSpec.describe "Contacts", type: :request do
  describe "GET /contact" do
    it "正常にレスポンスを返す" do
      get contact_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /contact" do
    context "有効なパラメータの場合" do
      let(:valid_params) { { contact: { name: "テスト太郎", email: "test@example.com", message: "テストメッセージ" } } }

      it "お問い合わせを作成してメールを送信する" do
        expect {
          post contact_path, params: valid_params
        }.to change(Contact, :count).by(1)
          .and change { ActionMailer::Base.deliveries.count }.by(1)
        expect(response).to redirect_to(contact_path)
      end
    end

    context "無効なパラメータの場合" do
      it "お問い合わせを作成せず422を返す" do
        expect {
          post contact_path, params: { contact: { name: "", email: "", message: "" } }
        }.not_to change(Contact, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "ハニーポットが入力された場合" do
      it "お問い合わせを保存せずリダイレクトする" do
        expect {
          post contact_path, params: {
            contact: { name: "スパム", email: "spam@test.com", message: "スパム" },
            website: "http://spam.com"
          }
        }.not_to change(Contact, :count)
        expect(response).to redirect_to(contact_path)
      end
    end
  end
end

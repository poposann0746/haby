require "rails_helper"

RSpec.describe "StaticPages", type: :request do
  describe "GET /privacy" do
    it "正常にレスポンスを返す" do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /terms" do
    it "正常にレスポンスを返す" do
      get terms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /guide" do
    it "正常にレスポンスを返す" do
      get guide_path
      expect(response).to have_http_status(:ok)
    end
  end
end

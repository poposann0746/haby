# frozen_string_literal: true

require "test_helper"

class UserRememberMeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "login form displays remember me checkbox" do
    get new_user_session_path
    assert_response :success
    assert_select "input[type=checkbox][name='user[remember_me]']"
    assert_select "label", text: "ログイン状態を保持する"
  end

  test "login with remember me sets remember cookie" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password",
        remember_me: "1"
      }
    }
    assert_response :redirect
    follow_redirect!

    # remember_user_tokenクッキーが設定されていることを確認
    assert cookies["remember_user_token"].present?, "remember_user_token cookie should be set"
  end

  test "login without remember me does not set remember cookie" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password",
        remember_me: "0"
      }
    }
    assert_response :redirect
    follow_redirect!

    # remember_user_tokenクッキーが設定されていないことを確認
    assert cookies["remember_user_token"].blank?, "remember_user_token cookie should not be set"
  end

  test "logout clears remember cookie" do
    # ログイン（remember_me有効）
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password",
        remember_me: "1"
      }
    }
    follow_redirect!
    assert cookies["remember_user_token"].present?

    # ログアウト
    delete destroy_user_session_path
    follow_redirect!

    # remember_user_tokenクッキーがクリアされていることを確認
    assert cookies["remember_user_token"].blank?, "remember_user_token cookie should be cleared after logout"
  end

  test "user remember_created_at is set when remember me is enabled" do
    assert_nil @user.remember_created_at

    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password",
        remember_me: "1"
      }
    }

    @user.reload
    assert_not_nil @user.remember_created_at, "remember_created_at should be set"
  end
end

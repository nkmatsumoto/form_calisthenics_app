require "test_helper"

class HealthAndHomeTest < ActionDispatch::IntegrationTest
  test "health endpoint returns success" do
    get rails_health_check_path
    assert_response :success
  end

  test "anonymous home page loads" do
    get root_path
    assert_response :success
  end

  test "anonymous users are redirected from dashboard" do
    get dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "anonymous users are redirected from calendar" do
    get calendar_path
    assert_redirected_to new_user_session_path
  end
end

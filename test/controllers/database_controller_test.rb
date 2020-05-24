require 'test_helper'

class DatabaseControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get table" do
    get :table
    assert_response :success
  end

end

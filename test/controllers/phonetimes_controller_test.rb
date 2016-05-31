require 'test_helper'

class PhonetimesControllerTest < ActionController::TestCase
  setup do
    @phonetime = phonetimes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:phonetimes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create phonetime" do
    assert_difference('Phonetime.count') do
      post :create, phonetime: { doctor_id: @phonetime.doctor_id, message: @phonetime.message }
    end

    assert_redirected_to phonetime_path(assigns(:phonetime))
  end

  test "should show phonetime" do
    get :show, id: @phonetime
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @phonetime
    assert_response :success
  end

  test "should update phonetime" do
    patch :update, id: @phonetime, phonetime: { doctor_id: @phonetime.doctor_id, message: @phonetime.message }
    assert_redirected_to phonetime_path(assigns(:phonetime))
  end

  test "should destroy phonetime" do
    assert_difference('Phonetime.count', -1) do
      delete :destroy, id: @phonetime
    end

    assert_redirected_to phonetimes_path
  end
end

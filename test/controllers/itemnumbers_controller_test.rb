require 'test_helper'

class ItemnumbersControllerTest < ActionController::TestCase
  setup do
    @itemnumber = itemnumbers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:itemnumbers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create itemnumber" do
    assert_difference('Itemnumber.count') do
      post :create, itemnumber: { mbs: @itemnumber.mbs, name: @itemnumber.name }
    end

    assert_redirected_to itemnumber_path(assigns(:itemnumber))
  end

  test "should show itemnumber" do
    get :show, id: @itemnumber
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @itemnumber
    assert_response :success
  end

  test "should update itemnumber" do
    patch :update, id: @itemnumber, itemnumber: { mbs: @itemnumber.mbs, name: @itemnumber.name }
    assert_redirected_to itemnumber_path(assigns(:itemnumber))
  end

  test "should destroy itemnumber" do
    assert_difference('Itemnumber.count', -1) do
      delete :destroy, id: @itemnumber
    end

    assert_redirected_to itemnumbers_path
  end
end

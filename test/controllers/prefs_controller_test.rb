require 'test_helper'

class PrefsControllerTest < ActionController::TestCase
  setup do
    @pref = prefs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prefs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pref" do
    assert_difference('Pref.count') do
      post :create, pref: { name: @pref.name, value: @pref.value }
    end

    assert_redirected_to pref_path(assigns(:pref))
  end

  test "should show pref" do
    get :show, id: @pref
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pref
    assert_response :success
  end

  test "should update pref" do
    patch :update, id: @pref, pref: { name: @pref.name, value: @pref.value }
    assert_redirected_to pref_path(assigns(:pref))
  end

  test "should destroy pref" do
    assert_difference('Pref.count', -1) do
      delete :destroy, id: @pref
    end

    assert_redirected_to prefs_path
  end
end

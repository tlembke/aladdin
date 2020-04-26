require 'test_helper'

class ConsultsControllerTest < ActionController::TestCase
  setup do
    @consult = consults(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:consults)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create consult" do
    assert_difference('Consult.count') do
      post :create, consult: { billed: @consult.billed, complete: @consult.complete, consultdate: @consult.consultdate, mbs: @consult.mbs, notes: @consult.notes, patient_id: @consult.patient_id, provider_id: @consult.provider_id, type: @consult.type }
    end

    assert_redirected_to consult_path(assigns(:consult))
  end

  test "should show consult" do
    get :show, id: @consult
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @consult
    assert_response :success
  end

  test "should update consult" do
    patch :update, id: @consult, consult: { billed: @consult.billed, complete: @consult.complete, consultdate: @consult.consultdate, mbs: @consult.mbs, notes: @consult.notes, patient_id: @consult.patient_id, provider_id: @consult.provider_id, type: @consult.type }
    assert_redirected_to consult_path(assigns(:consult))
  end

  test "should destroy consult" do
    assert_difference('Consult.count', -1) do
      delete :destroy, id: @consult
    end

    assert_redirected_to consults_path
  end
end

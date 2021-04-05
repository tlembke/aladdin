require 'test_helper'

class ClinicsControllerTest < ActionController::TestCase
  setup do
    @clinic = clinics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clinics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clinic" do
    assert_difference('Clinic.count') do
      post :create, clinic: { ATSIage: @clinic.ATSIage, age: @clinic.age, chronic: @clinic.chronic, chronicage: @clinic.chronicage, clinicdate: @clinic.clinicdate, finishhour: @clinic.finishhour, finishminute: @clinic.finishminute, message: @clinic.message, perhour: @clinic.perhour, starthour: @clinic.starthour, startminute: @clinic.startminute, template: @clinic.template, vaxtype: @clinic.vaxtype, venue: @clinic.venue }
    end

    assert_redirected_to clinic_path(assigns(:clinic))
  end

  test "should show clinic" do
    get :show, id: @clinic
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @clinic
    assert_response :success
  end

  test "should update clinic" do
    patch :update, id: @clinic, clinic: { ATSIage: @clinic.ATSIage, age: @clinic.age, chronic: @clinic.chronic, chronicage: @clinic.chronicage, clinicdate: @clinic.clinicdate, finishhour: @clinic.finishhour, finishminute: @clinic.finishminute, message: @clinic.message, perhour: @clinic.perhour, starthour: @clinic.starthour, startminute: @clinic.startminute, template: @clinic.template, vaxtype: @clinic.vaxtype, venue: @clinic.venue }
    assert_redirected_to clinic_path(assigns(:clinic))
  end

  test "should destroy clinic" do
    assert_difference('Clinic.count', -1) do
      delete :destroy, id: @clinic
    end

    assert_redirected_to clinics_path
  end
end

require 'test_helper'

class MeasurementsControllerTest < ActionController::TestCase
  setup do
    @measure_value = measure_values(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:measure_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create measure_value" do
    assert_difference('Measurement.count') do
      post :create, measure_value: { measure_id: @measure_value.measure_id, measuredate: @measure_value.measuredate, patient_id: @measure_value.patient_id, value: @measure_value.value }
    end

    assert_redirected_to measure_value_path(assigns(:measure_value))
  end

  test "should show measure_value" do
    get :show, id: @measure_value
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @measure_value
    assert_response :success
  end

  test "should update measure_value" do
    patch :update, id: @measure_value, measure_value: { measure_id: @measure_value.measure_id, measuredate: @measure_value.measuredate, patient_id: @measure_value.patient_id, value: @measure_value.value }
    assert_redirected_to measure_value_path(assigns(:measure_value))
  end

  test "should destroy measure_value" do
    assert_difference('Measurement.count', -1) do
      delete :destroy, id: @measure_value
    end

    assert_redirected_to measure_values_path
  end
end

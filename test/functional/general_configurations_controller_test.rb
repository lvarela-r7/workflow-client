require 'test_helper'

class GeneralConfigurationsControllerTest < ActionController::TestCase
  setup do
    @general_configuration = general_configurations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:integer_property)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create general_configuration" do
    assert_difference('GeneralConfiguration.count') do
      post :create, :general_configuration => @general_configuration.attributes
    end

    assert_redirected_to general_configuration_path(assigns(:general_configuration))
  end

  test "should show general_configuration" do
    get :show, :id => @general_configuration.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @general_configuration.to_param
    assert_response :success
  end

  test "should update general_configuration" do
    put :update, :id => @general_configuration.to_param, :general_configuration => @general_configuration.attributes
    assert_redirected_to general_configuration_path(assigns(:general_configuration))
  end

  test "should destroy general_configuration" do
    assert_difference('GeneralConfiguration.count', -1) do
      delete :destroy, :id => @general_configuration.to_param
    end

    assert_redirected_to general_configurations_path
  end
end

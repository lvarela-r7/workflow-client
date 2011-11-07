require 'test_helper'

class NscConfigsControllerTest < ActionController::TestCase
  setup do
    @nsc_config = nsc_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nsc_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nsc_config" do
    assert_difference('NscConfig.count') do
      post :create, :nsc_config => @nsc_config.attributes
    end

    assert_redirected_to nsc_config_path(assigns(:nsc_config))
  end

  test "should show nsc_config" do
    get :show, :id => @nsc_config.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @nsc_config.to_param
    assert_response :success
  end

  test "should update nsc_config" do
    put :update, :id => @nsc_config.to_param, :nsc_config => @nsc_config.attributes
    assert_redirected_to nsc_config_path(assigns(:nsc_config))
  end

  test "should destroy nsc_config" do
    assert_difference('NscConfig.count', -1) do
      delete :destroy, :id => @nsc_config.to_param
    end

    assert_redirected_to nsc_configs_path
  end
end

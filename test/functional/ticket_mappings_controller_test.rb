require 'test_helper'

class TicketMappingsControllerTest < ActionController::TestCase
  setup do
    @ticket_mapping = ticket_mappings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ticket_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ticket_mapping" do
    assert_difference('TicketMapping.count') do
      post :create, :ticket_mapping => @ticket_mapping.attributes
    end

    assert_redirected_to ticket_mapping_path(assigns(:ticket_mapping))
  end

  test "should show ticket_mapping" do
    get :show, :id => @ticket_mapping.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ticket_mapping.to_param
    assert_response :success
  end

  test "should update ticket_mapping" do
    put :update, :id => @ticket_mapping.to_param, :ticket_mapping => @ticket_mapping.attributes
    assert_redirected_to ticket_mapping_path(assigns(:ticket_mapping))
  end

  test "should destroy ticket_mapping" do
    assert_difference('TicketMapping.count', -1) do
      delete :destroy, :id => @ticket_mapping.to_param
    end

    assert_redirected_to ticket_mappings_path
  end
end

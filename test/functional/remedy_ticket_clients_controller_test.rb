require 'test_helper'

class RemedyTicketClientsControllerTest < ActionController::TestCase
  setup do
    @remedy_ticket_client = remedy_ticket_clients(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:remedy_ticket_clients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create remedy_ticket_client" do
    assert_difference('RemedyTicketClient.count') do
      post :create, :remedy_ticket_client => @remedy_ticket_client.attributes
    end

    assert_redirected_to remedy_ticket_client_path(assigns(:remedy_ticket_client))
  end

  test "should show remedy_ticket_client" do
    get :show, :id => @remedy_ticket_client.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @remedy_ticket_client.to_param
    assert_response :success
  end

  test "should update remedy_ticket_client" do
    put :update, :id => @remedy_ticket_client.to_param, :remedy_ticket_client => @remedy_ticket_client.attributes
    assert_redirected_to remedy_ticket_client_path(assigns(:remedy_ticket_client))
  end

  test "should destroy remedy_ticket_client" do
    assert_difference('RemedyTicketClient.count', -1) do
      delete :destroy, :id => @remedy_ticket_client.to_param
    end

    assert_redirected_to remedy_ticket_clients_path
  end
end

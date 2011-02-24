require 'test_helper'

class SuscriptorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:suscriptors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create suscriptor" do
    assert_difference('Suscriptor.count') do
      post :create, :suscriptor => { }
    end

    assert_redirected_to suscriptor_path(assigns(:suscriptor))
  end

  test "should show suscriptor" do
    get :show, :id => suscriptors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => suscriptors(:one).to_param
    assert_response :success
  end

  test "should update suscriptor" do
    put :update, :id => suscriptors(:one).to_param, :suscriptor => { }
    assert_redirected_to suscriptor_path(assigns(:suscriptor))
  end

  test "should destroy suscriptor" do
    assert_difference('Suscriptor.count', -1) do
      delete :destroy, :id => suscriptors(:one).to_param
    end

    assert_redirected_to suscriptors_path
  end
end

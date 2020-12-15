require 'test_helper'

class DocsControllerTest < ActionController::TestCase
  setup do
    @doc = docs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:docs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create doc" do
    assert_difference('Doc.count') do
      post :create, doc: { cat: @doc.cat, description: @doc.description, filename: @doc.filename, name: @doc.name, thumbnail: @doc.thumbnail }
    end

    assert_redirected_to doc_path(assigns(:doc))
  end

  test "should show doc" do
    get :show, id: @doc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @doc
    assert_response :success
  end

  test "should update doc" do
    patch :update, id: @doc, doc: { cat: @doc.cat, description: @doc.description, filename: @doc.filename, name: @doc.name, thumbnail: @doc.thumbnail }
    assert_redirected_to doc_path(assigns(:doc))
  end

  test "should destroy doc" do
    assert_difference('Doc.count', -1) do
      delete :destroy, id: @doc
    end

    assert_redirected_to docs_path
  end
end

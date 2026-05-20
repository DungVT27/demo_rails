require 'rails_helper'

RSpec.describe "Admin::Stores", type: :request do
  let(:admin_user) do
    User.create!(
      name: "Admin User",
      email: "admin_test@example.com",
      password: "password123",
      role: :admin
    )
  end

  before do
    sign_in admin_user
  end

  describe "POST /admin/stores" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          name: "Test Store",
          address: "123 Test Street",
          opening_time: "08:00",
          closing_time: "17:00",
          booking_fee: 100,
          status: "active"
        }
      end

      it "creates a new Store" do
        expect {
          post admin_stores_path, params: { store: valid_attributes }
        }.to change(Store, :count).by(1)
      end

      it "redirects to the created store" do
        post admin_stores_path, params: { store: valid_attributes }
        expect(response).to redirect_to(admin_store_path(Store.last))
        expect(flash[:success]).to eq(I18n.t("messages.admin.stores.create_success", name: Store.last.name))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          name: "",
          address: "123 Test Street",
          opening_time: "18:00", # invalid because > 17:00
          closing_time: "19:00",
          booking_fee: -10,      # invalid because < 0
          status: "active"
        }
      end

      it "does not create a new Store" do
        expect {
          post admin_stores_path, params: { store: invalid_attributes }
        }.to change(Store, :count).by(0)
      end

      it "renders the new template with unprocessable_content status" do
        post admin_stores_path, params: { store: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to eq("Failed to create store. Please review the errors below.")
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Admin::Stores", type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin@test.com", password: "password", role: :admin) }
  let(:user) { User.create!(name: "User", email: "user@test.com", password: "password", role: :user) }
  let!(:store) { Store.create!(name: "Store 1", address: "123", opening_time: "08:00", closing_time: "17:00", booking_fee: 10, status: :active) }

  context "when not logged in" do
    it "redirects to sign in page" do
      get admin_stores_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when logged in as user" do
    before { sign_in user }

    it "redirects to root path" do
      get admin_stores_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "when logged in as admin" do
    before { sign_in admin }

    describe "GET /admin/stores" do
      it "returns http success" do
        get admin_stores_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/stores/:id" do
      it "returns http success" do
        get admin_store_path(store)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/stores" do
      let(:valid_params) { { store: { name: "New Store", address: "456", opening_time: "09:00", closing_time: "17:00", booking_fee: 20, status: :active } } }
      let(:invalid_params) { { store: { name: "" } } }

      it "creates a new store with valid params" do
        expect { post admin_stores_path, params: valid_params }.to change(Store, :count).by(1)
        expect(response).to redirect_to(admin_store_path(Store.last))
      end

      it "does not create with invalid params" do
        expect { post admin_stores_path, params: invalid_params }.not_to change(Store, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "PATCH /admin/stores/:id" do
      it "updates the store" do
        patch admin_store_path(store), params: { store: { name: "Updated Name" } }
        store.reload
        expect(store.name).to eq("Updated Name")
        expect(response).to redirect_to(admin_store_path(store))
      end
    end

    describe "DELETE /admin/stores/:id" do
      it "soft deletes the store" do
        expect { delete admin_store_path(store) }.to change(Store.active, :count).by(-1)
        expect(store.reload.deleted_at).to be_present
        expect(response).to redirect_to(admin_stores_path)
      end
    end
  end
end

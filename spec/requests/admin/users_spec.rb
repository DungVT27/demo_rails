require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin3@test.com", password: "password", role: :admin) }
  let!(:user) { User.create!(name: "User", email: "user3@test.com", password: "password", role: :user) }

  context "when not logged in" do
    it "redirects to sign in page" do
      get admin_users_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when logged in as admin" do
    before { sign_in admin }

    describe "GET /admin/users" do
      it "returns http success" do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/users/:id" do
      it "returns http success" do
        get admin_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    describe "DELETE /admin/users/:id" do
      it "soft deletes the user" do
        expect { delete admin_user_path(user) }.to change(User, :count).by(-1)
        expect(user.reload.deleted_at).to be_present
        expect(response).to redirect_to(admin_users_path)
      end

      it "does not allow deleting oneself" do
        delete admin_user_path(admin)
        expect(flash[:alert]).to be_present
        expect(admin.reload.deleted_at).to be_nil
      end
    end

    describe "DELETE /admin/users/bulk_destroy" do
      let!(:user2) { User.create!(name: "User 2", email: "user4@test.com", password: "password", role: :user) }

      it "soft deletes multiple users" do
        expect { delete bulk_destroy_admin_users_path, params: { user_ids: [user.id, user2.id] } }.to change(User, :count).by(-2)
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end

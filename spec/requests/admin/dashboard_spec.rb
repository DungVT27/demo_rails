require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin5@test.com", password: "password", role: :admin) }

  context "when logged in as admin" do
    before { sign_in admin }

    describe "GET /admin/dashboard" do
      it "returns http success" do
        get admin_dashboard_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "User::Stores", type: :request do
  let!(:store) { Store.create!(name: "Store 1", address: "123", opening_time: "08:00", closing_time: "17:00", booking_fee: 10, status: :active) }
  let!(:inactive_store) { Store.create!(name: "Store 2", address: "456", opening_time: "09:00", closing_time: "17:00", booking_fee: 20, status: :inactive) }

  describe "GET /stores" do
    it "returns http success" do
      get stores_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /stores/:id" do
    it "returns http success for active store" do
      get store_path(store)
      expect(response).to have_http_status(:success)
    end

    it "raises RecordNotFound for inactive store" do
      get store_path(inactive_store)
      expect(response).to have_http_status(:not_found)
    end
  end
end

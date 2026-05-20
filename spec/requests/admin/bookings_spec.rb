require 'rails_helper'

RSpec.describe "Admin::Bookings", type: :request do
  let(:admin) { User.create!(name: "Admin", email: "admin2@test.com", password: "password", role: :admin) }
  let(:user) { User.create!(name: "User", email: "user2@test.com", password: "password", role: :user) }
  let(:store) { Store.create!(name: "Store", address: "123", opening_time: "08:00", closing_time: "17:00", booking_fee: 10, status: :active) }
  let!(:booking) { Booking.create!(user: user, store: store, booking_date: Date.tomorrow, booking_time: "10:00", status: :approved) }

  context "when not logged in" do
    it "redirects to sign in page" do
      get admin_bookings_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when logged in as admin" do
    before { sign_in admin }

    describe "GET /admin/bookings" do
      it "returns http success" do
        get admin_bookings_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/bookings/:id" do
      it "returns http success" do
        get admin_booking_path(booking)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/bookings/:id/cancel" do
      it "cancels the booking" do
        patch cancel_admin_booking_path(booking)
        expect(booking.reload.status).to eq("cancelled")
        expect(response).to redirect_to(admin_bookings_path)
      end
    end

    describe "PATCH /admin/bookings/:id/complete" do
      let!(:approved_booking) { Booking.create!(user: user, store: store, booking_date: Date.tomorrow, booking_time: "11:00", status: :approved) }

      it "completes the booking" do
        patch complete_admin_booking_path(approved_booking)
        expect(approved_booking.reload.status).to eq("completed")
        expect(response).to redirect_to(admin_bookings_path)
      end
    end
  end
end

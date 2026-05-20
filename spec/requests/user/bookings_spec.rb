require 'rails_helper'

RSpec.describe "User::Bookings", type: :request do
  let(:user) { User.create!(name: "User", email: "user10@test.com", password: "password", role: :user) }
  let(:store) { Store.create!(name: "Store 1", address: "123", opening_time: "08:00", closing_time: "17:00", booking_fee: 10, status: :active) }
  let!(:booking) { Booking.create!(user: user, store: store, booking_date: 2.days.from_now.to_date, booking_time: "10:00", status: :approved) }

  context "when not logged in" do
    it "redirects to sign in page" do
      get bookings_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when logged in" do
    before { sign_in user }

    describe "GET /bookings" do
      it "returns http success" do
        get bookings_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /bookings" do
      let(:valid_params) { { booking: { store_id: store.id, booking_date: 3.days.from_now.to_date.to_s, booking_time: "11:00" } } }
      let(:invalid_params) { { booking: { store_id: store.id, booking_date: Date.yesterday.to_s, booking_time: "11:00" } } }

      it "creates a new booking" do
        expect { post bookings_path, params: valid_params }.to change(Booking, :count).by(1)
        expect(response).to redirect_to(bookings_path)
      end

      it "does not create with invalid params" do
        expect { post bookings_path, params: invalid_params }.not_to change(Booking, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "PATCH /bookings/:id/cancel" do
      it "cancels the booking" do
        patch cancel_booking_path(booking)
        expect(booking.reload.status).to eq("cancelled")
        expect(response).to redirect_to(bookings_path)
      end
    end
  end
end

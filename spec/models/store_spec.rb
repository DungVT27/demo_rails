require 'rails_helper'

RSpec.describe Store, type: :model do
  describe "Validations" do
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

    it "is valid with valid attributes" do
      store = Store.new(valid_attributes)
      expect(store).to be_valid
    end

    it "is not valid without a name" do
      store = Store.new(valid_attributes.merge(name: ""))
      expect(store).not_to be_valid
      expect(store.errors[:name]).to include("can't be blank")
    end

    it "is not valid with a negative booking fee" do
      store = Store.new(valid_attributes.merge(booking_fee: -10))
      expect(store).not_to be_valid
      expect(store.errors[:booking_fee]).to include("must be greater than or equal to 0")
    end

    describe "working hours validations" do
      it "is not valid if opening_time is before 08:00" do
        store = Store.new(valid_attributes.merge(opening_time: "07:59"))
        expect(store).not_to be_valid
        expect(store.errors[:opening_time]).to include("cannot be earlier than 08:00")
      end

      it "is not valid if closing_time is after 17:00" do
        store = Store.new(valid_attributes.merge(closing_time: "17:01"))
        expect(store).not_to be_valid
        expect(store.errors[:closing_time]).to include("cannot be later than 17:00")
      end

      it "is not valid if closing_time is before or equal to opening_time" do
        store = Store.new(valid_attributes.merge(opening_time: "10:00", closing_time: "09:00"))
        expect(store).not_to be_valid
        expect(store.errors[:closing_time]).to include("must be after the opening time")
      end
    end
  end
end

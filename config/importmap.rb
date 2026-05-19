# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "global_alerts", to: "global_alerts.js"
pin "store_booking", to: "store_booking.js"
pin "user_bulk_delete", to: "user_bulk_delete.js"

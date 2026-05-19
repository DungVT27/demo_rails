(function() {
  function initDynamicTimeDisabling() {
    const dateInput = document.getElementById("booking_date_input");
    const timeSelect = document.getElementById("booking_time_select");

    if (dateInput && timeSelect) {
      function updateSelectableTimes() {
        const selectedDateStr = dateInput.value;
        if (!selectedDateStr) return;

        // Create a standard Date object for comparing selected date with today's date
        const parts = selectedDateStr.split("-");
        const selectedYear = parseInt(parts[0], 10);
        const selectedMonth = parseInt(parts[1], 10) - 1;
        const selectedDay = parseInt(parts[2], 10);
        const selectedDate = new Date(selectedYear, selectedMonth, selectedDay);

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const isToday = selectedDate.getTime() === today.getTime();
        const currentHour = new Date().getHours();

        Array.from(timeSelect.options).forEach(option => {
          if (!option.value) return;

          // Retrieve slot hour from value (e.g. "09:00" -> 9)
          const optionHour = parseInt(option.value.split(":")[0], 10);

          if (isToday && optionHour <= currentHour) {
            option.disabled = true;
            if (option.selected) {
              timeSelect.value = ""; // Clear selection if it was a past slot
            }
          } else {
            option.disabled = false;
          }
        });
      }

      // Bind event listeners
      dateInput.addEventListener("change", updateSelectableTimes);
      // Run initial assessment
      updateSelectableTimes();
    }
  }

  // Initialize on DOM load and subsequent Turbo transitions
  document.addEventListener("DOMContentLoaded", initDynamicTimeDisabling);
  document.addEventListener("turbo:load", initDynamicTimeDisabling);
})();

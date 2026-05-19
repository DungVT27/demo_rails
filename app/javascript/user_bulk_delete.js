(function() {
  function initBulkDelete() {
    const selectAllCheckbox = document.getElementById("select-all");
    const userCheckboxes = document.querySelectorAll(".user-checkbox");
    const bulkDeleteBtn = document.getElementById("bulk-delete-btn");
    const selectedCountLabel = document.getElementById("selected-count");
    const modalSelectedCount = document.getElementById("modal-selected-count");
    const confirmBulkDeleteBtn = document.getElementById("confirm-bulk-delete-btn");
    const bulkDeleteForm = document.getElementById("bulk-delete-form");

    if (!selectAllCheckbox || selectAllCheckbox.dataset.initialized) return;
    selectAllCheckbox.dataset.initialized = "true";

    function updateBulkButtonState() {
      const checkedBoxes = document.querySelectorAll(".user-checkbox:checked");
      const checkedCount = checkedBoxes.length;

      // Update label count
      if (selectedCountLabel) {
        selectedCountLabel.textContent = checkedCount + " user(s) selected";
      }

      // Update modal selected count
      if (modalSelectedCount) {
        modalSelectedCount.textContent = checkedCount;
      }

      // Visual and physical state toggle for the button
      if (bulkDeleteBtn) {
        if (checkedCount > 0) {
          bulkDeleteBtn.disabled = false;
          bulkDeleteBtn.removeAttribute("disabled");
          bulkDeleteBtn.style.opacity = "1";
          bulkDeleteBtn.style.cursor = "pointer";
        } else {
          bulkDeleteBtn.disabled = true;
          bulkDeleteBtn.setAttribute("disabled", "disabled");
          bulkDeleteBtn.style.opacity = "0.6";
          bulkDeleteBtn.style.cursor = "not-allowed";
        }
      }
    }

    // Toggle all checkboxes when select-all is clicked
    selectAllCheckbox.addEventListener("change", function() {
      userCheckboxes.forEach(checkbox => {
        checkbox.checked = selectAllCheckbox.checked;
      });
      updateBulkButtonState();
    });

    // Toggle individual checkbox changes
    userCheckboxes.forEach(checkbox => {
      checkbox.addEventListener("change", function() {
        if (!checkbox.checked) {
          selectAllCheckbox.checked = false;
        } else {
          const allChecked = Array.from(userCheckboxes).every(cb => cb.checked);
          selectAllCheckbox.checked = allChecked;
        }
        updateBulkButtonState();
      });
    });

    // Submit form when confirmed in modal
    if (confirmBulkDeleteBtn && bulkDeleteForm) {
      confirmBulkDeleteBtn.addEventListener("click", function() {
        // Hide modal using Bootstrap APIs if available to avoid backdrop issues
        const modalEl = document.getElementById("bulkDeleteConfirmModal");
        if (modalEl && window.bootstrap) {
          const modalInstance = bootstrap.Modal.getInstance(modalEl);
          if (modalInstance) {
            modalInstance.hide();
          }
        }
        
        // Use requestSubmit to properly trigger Turbo/CSRF token inclusion
        if (typeof bulkDeleteForm.requestSubmit === "function") {
          bulkDeleteForm.requestSubmit();
        } else {
          bulkDeleteForm.submit();
        }
      });
    }

    // Initial state call
    updateBulkButtonState();
  }

  // Bind to multiple events to ensure absolute load resilience
  document.addEventListener("DOMContentLoaded", initBulkDelete);
  document.addEventListener("turbo:load", initBulkDelete);

  // In case scripts load after page is ready
  if (document.readyState === "interactive" || document.readyState === "complete") {
    initBulkDelete();
  }
})();

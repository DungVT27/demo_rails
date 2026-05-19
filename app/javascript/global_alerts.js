(function() {
  let savedUrl = "";
  let savedMethod = "delete";

  function initGlobalDeleteTriggers() {
    document.querySelectorAll(".btn-delete-trigger").forEach(element => {
      if (element.dataset.globalInitialized) return;
      element.dataset.globalInitialized = "true";

      element.addEventListener("click", function(event) {
        event.preventDefault();
        event.stopPropagation();

        savedUrl = element.getAttribute("data-url");
        savedMethod = element.getAttribute("data-method") || "delete";
        const message = element.getAttribute("data-message") || "Are you sure you want to delete this?";

        const modalTitle = document.getElementById("global-modal-title");
        const modalBody = document.getElementById("global-modal-body");

        if (modalTitle) modalTitle.textContent = "Are you absolutely sure?";
        if (modalBody) modalBody.textContent = message;

        const modalEl = document.getElementById("globalDeleteConfirmModal");
        if (modalEl && window.bootstrap) {
          const modalInstance = new bootstrap.Modal(modalEl);
          modalInstance.show();
        }
      });
    });
  }

  function initBootstrapDropdowns() {
    if (window.bootstrap && bootstrap.Dropdown) {
      document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(toggle => {
        let instance = bootstrap.Dropdown.getInstance(toggle);
        if (instance) {
          instance.dispose();
        }
        new bootstrap.Dropdown(toggle);
      });
    }
  }

  function autoDismissAlerts() {
    document.querySelectorAll(".premium-alert").forEach(alert => {
      if (alert.dataset.dismissScheduled) return;
      alert.dataset.dismissScheduled = "true";

      setTimeout(() => {
        if (window.bootstrap && bootstrap.Alert) {
          let alertInstance = bootstrap.Alert.getInstance(alert) || new bootstrap.Alert(alert);
          if (alertInstance) {
            alertInstance.close();
          }
        } else {
          alert.classList.remove("show");
          setTimeout(() => alert.remove(), 150);
        }
      }, 5000);
    });
  }

  // Initialize on both DOMContentLoaded and Turbo page transitions
  document.addEventListener("DOMContentLoaded", function() {
    initGlobalDeleteTriggers();
    initBootstrapDropdowns();
    autoDismissAlerts();
  });
  document.addEventListener("turbo:load", function() {
    initGlobalDeleteTriggers();
    initBootstrapDropdowns();
    autoDismissAlerts();
  });

  // Use global document-level delegated click listener for the confirm button to support Turbo
  document.addEventListener("click", function(event) {
    const confirmBtn = event.target.closest("#confirm-global-delete-btn");
    if (!confirmBtn) return;

    if (!savedUrl) return;

    // Close modal cleanly
    const modalEl = document.getElementById("globalDeleteConfirmModal");
    if (modalEl && window.bootstrap) {
      const modalInstance = bootstrap.Modal.getInstance(modalEl);
      if (modalInstance) modalInstance.hide();
    }

    // Create dynamic form to submit DELETE request
    const form = document.createElement("form");
    form.method = "POST";
    form.action = savedUrl;

    // CSRF Token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    if (csrfToken) {
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = "authenticity_token";
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);
    }

    // Method override
    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = savedMethod;
    form.appendChild(methodInput);

    document.body.appendChild(form);
    form.submit();
  });
})();

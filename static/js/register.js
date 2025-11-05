document.addEventListener("DOMContentLoaded", () => {
  // ===== PASSWORD TOGGLE =====
  const toggles = document.querySelectorAll(".toggle-password");

  toggles.forEach(span => {
    span.addEventListener("click", function() {
      const wrapper = this.closest(".password-wrapper");
      const input = wrapper.querySelector("input");

      if (input.type === "password") {
        input.type = "text";
        this.textContent = "🔓";
      } else {
        input.type = "password";
        this.textContent = "🔒";
      }
    });
  });

  // ===== ROLE DROPDOWN =====
  const roleDropdown = document.querySelector('.role-dropdown'); // fixed
  const vetFields = document.getElementById('vet-fields');
  const ngoFields = document.getElementById('ngo-fields');

  if (vetFields) vetFields.style.display = "none";
  if (ngoFields) ngoFields.style.display = "none";

  if (roleDropdown) {
    roleDropdown.addEventListener('change', function() {
      if (this.value === 'vet') {
        if (vetFields) vetFields.style.display = 'block';
        if (ngoFields) ngoFields.style.display = 'none';
      } else if (this.value === 'ngo') {
        if (vetFields) vetFields.style.display = 'none';
        if (ngoFields) ngoFields.style.display = 'block';
      } else {
        if (vetFields) vetFields.style.display = 'none';
        if (ngoFields) ngoFields.style.display = 'none';
      }
    });
  }

  // ===== CONFIRM PASSWORD CHECK =====
  const passwordInput = document.getElementById("password");
  const confirmInput = document.getElementById("confirm_password"); // fixed
  const message = document.getElementById("password-match-status"); // fixed

  if (passwordInput && confirmInput && message) {
    const checkPasswords = () => {
      const pass = passwordInput.value.trim();
      const confirm = confirmInput.value.trim();

      if (!confirm) {
        message.textContent = "";
      } else if (confirm !== pass) {
        message.textContent = "⚠️ Passwords do not match";
        message.style.color = "red";
      } else {
        message.textContent = "✅ Passwords match";
        message.style.color = "green";
      }
    };

    confirmInput.addEventListener("input", checkPasswords);
    passwordInput.addEventListener("input", checkPasswords);
  }

  // ===== EMAIL & PHONE VALIDATION =====
  const form = document.querySelector("form");
  if (form) {
    const emailInput = form.querySelector('input[name="email"]');
    const phoneInput = form.querySelector('input[name="phone_number"]'); // fixed

    form.addEventListener("submit", (e) => {
      let valid = true;

      // Email validation
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailPattern.test(emailInput.value.trim())) {
        alert("Please enter a valid email address");
        valid = false;
      }

      // Phone validation (must be 10 digits if entered)
      const phoneVal = phoneInput.value.trim();
      if (phoneVal !== "" && !/^\d{10}$/.test(phoneVal)) {
        alert("Phone number must be 10 digits");
        valid = false;
      }

      if (!valid) e.preventDefault();
    });
  }
});

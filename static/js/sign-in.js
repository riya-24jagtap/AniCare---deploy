document.addEventListener('DOMContentLoaded', () => {
  // Password toggle functionality
  const togglePassword = document.querySelector('.toggle-password');
  const passwordInput = document.querySelector('input[name="password"]');

  if (togglePassword && passwordInput) {
    togglePassword.style.cursor = 'pointer'; // makes it clear it's clickable
    togglePassword.addEventListener('click', () => {
      const isHidden = passwordInput.type === 'password';
      passwordInput.type = isHidden ? 'text' : 'password';
      togglePassword.textContent = isHidden ? '🔓' : '🔒';
    });
  }

  // Email validation
  const emailInput = document.querySelector('input[name="email"]');
  if (emailInput) {
    emailInput.addEventListener('input', () => {
      const pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
      if (!pattern.test(emailInput.value)) {
        emailInput.setCustomValidity("Please enter a valid email address");
      } else {
        emailInput.setCustomValidity("");
      }
    });
  }
});

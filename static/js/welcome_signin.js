// Placeholder for signup button
document.querySelector(".signup-btn").addEventListener("click", () => {
  alert("Sign-up functionality not implemented yet.");
});

document.querySelector(".signin-btn").addEventListener("click", () => {
  alert("Redirecting to Sign In...");
});

function togglePasswordVisibility() {
  const passwordInput = document.getElementById("password");
  const icon = document.querySelector(".toggle-password");

  if (passwordInput.type === "password") {
    passwordInput.type = "text";
    icon.textContent = "🔓"; 
  } else {
    passwordInput.type = "password";
    icon.textContent = "🔒"; 
  }
}
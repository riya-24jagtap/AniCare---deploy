// =====================
// MAIN DOM CONTENT LOADED
// =====================
document.addEventListener("DOMContentLoaded", function () {

  // --- DOM ELEMENTS ---
  const detectBtn = document.getElementById("detectBtn");
  const showNearbyBtn = document.getElementById("showNearbyBtn");
  const locationInput = document.getElementById("location");
  const locationInfo = document.getElementById("liveLocationInfo");
  const nearbyResultsDiv = document.getElementById("nearbyResults");
  const ngoDropdown = document.getElementById("ngo_id");
  const animalSelect = document.getElementById("animalType");
  const otherAnimalDiv = document.getElementById("otherAnimalDiv");

  // --- DETECT USER LOCATION ---
  detectBtn.addEventListener("click", () => {
    if (!navigator.geolocation) return alert("Geolocation is not supported by your browser.");

    navigator.geolocation.getCurrentPosition(async (position) => {
      const lat = position.coords.latitude;
      const lon = position.coords.longitude;

      document.getElementById("latitude").value = lat;
      document.getElementById("longitude").value = lon;

      try {
        const res = await fetch(`https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`);
        const data = await res.json();

        const city = data.address.city || data.address.town || data.address.village || data.address.state || "";
        const pincode = data.address.postcode || "";
        locationInput.value = city;
        locationInfo.textContent = `📍 Detected: ${city} ${pincode} (Lat: ${lat}, Lon: ${lon})`;

      } catch (err) {
        console.error("Reverse geocoding failed:", err);
        alert("Failed to detect location.");
      }
    }, () => alert("Unable to retrieve location. Please allow location permission."));
  });

  // --- FETCH NEARBY NGOS ---
  showNearbyBtn.addEventListener("click", async () => {
    const lat = parseFloat(document.getElementById("latitude").value);
    const lon = parseFloat(document.getElementById("longitude").value);
    if (!lat || !lon) return alert("Detect your location first.");

    ngoDropdown.innerHTML = '<option value="">-- Select an NGO --</option>';
    nearbyResultsDiv.innerHTML = "";

    try {
      const res = await fetch("/get_nearby", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ latitude: lat, longitude: lon })
      });

      if (!res.ok) throw new Error("Server error");
      const data = await res.json();

      if (!data.length) {
        nearbyResultsDiv.innerHTML = "<p>No nearby NGOs found.</p>";
        return;
      }

      nearbyResultsDiv.innerHTML = `<ul>${data.map(n => `<li>${n.name} — ${n.address || '-'} (${n.distance_km} km)</li>`).join("")}</ul>`;

      data.forEach(n => {
        const option = document.createElement("option");
        option.value = n.id;
        option.textContent = `${n.name} - ${n.address || '-'} (${n.distance_km} km)`;
        ngoDropdown.appendChild(option);
      });

    } catch (err) {
      console.error("Nearby fetch failed:", err);
      nearbyResultsDiv.innerHTML = "<p style='color:red;'>Failed to load nearby NGOs.</p>";
    }
  });

  // --- SHOW "OTHER" ANIMAL INPUT DYNAMICALLY ---
  animalSelect.addEventListener("change", function () {
    const otherInput = document.getElementById("otherAnimal");
    if (this.value === "other") {
      otherAnimalDiv.style.display = "block";
      otherInput.required = true;
    } else {
      otherAnimalDiv.style.display = "none";
      otherInput.value = "";
      otherInput.required = false;
    }
  });

  // --- SUBMIT FORM VIA JS ---
  const reportForm = document.getElementById("reportForm");
  reportForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const formData = new FormData(reportForm);

    try {
      const res = await fetch("/report_stray", {
        method: "POST",
        body: formData
      });

      if (!res.ok) throw new Error("Failed to submit report");

      alert("Report submitted!");
      reportForm.reset();
      otherAnimalDiv.style.display = "none";
      refreshReports();

    } catch (err) {
      console.error(err);
      alert("Failed to submit report.");
    }
  });

});

// =====================
// PHOTO UPLOAD PREVIEW
// =====================
function previewPhoto(input, previewId) {
  const preview = document.getElementById(previewId);
  preview.innerHTML = "";

  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function (e) {
      const wrapper = document.createElement("div");
      wrapper.style.position = "relative";
      wrapper.style.display = "inline-block";

      const img = document.createElement("img");
      img.src = e.target.result;
      wrapper.appendChild(img);

      const cancelBtn = document.createElement("span");
      cancelBtn.innerHTML = "&times;";
      cancelBtn.classList.add("cancel-btn");
      cancelBtn.onclick = () => clearPhoto(input.id, previewId);
      wrapper.appendChild(cancelBtn);

      preview.appendChild(wrapper);
    };
    reader.readAsDataURL(input.files[0]);
  }
}

function clearPhoto(inputId, previewId) {
  document.getElementById(inputId).value = "";
  document.getElementById(previewId).innerHTML = "";
}

// =====================
// REFRESH REPORTS TABLE
// =====================
async function refreshReports() {
  const res = await fetch("/get_user_reports");
  const data = await res.json();
  const tbody = document.querySelector("#reportsTable tbody");
  tbody.innerHTML = "";

  data.forEach(r => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${r.case_id}</td>
      <td>${r.animal_type}</td>
      <td>${r.description}</td>
      <td>${r.location}</td>
      <td>${r.ngo_name || '-'}</td>
      <td><span class="status-${r.status.toLowerCase().replace(' ', '-') }">${r.status}</span></td>
      <td>${r.report_datetime}</td>
    `;
    tbody.appendChild(tr);
  });
}

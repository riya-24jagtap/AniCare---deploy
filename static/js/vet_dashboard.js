document.addEventListener("DOMContentLoaded", async () => {
  const qs = s => document.querySelector(s);
  const qsa = s => Array.from(document.querySelectorAll(s));

  // ---------- Sidebar Navigation ----------
  const buttons = qsa("nav button");
  const sections = qsa(".section");

  async function showSection(sectionId) {
    sections.forEach(sec => {
      sec.style.display = sec.id === sectionId ? "block" : "none";
      sec.classList.toggle('active', sec.id === sectionId);
    });

    buttons.forEach(btn => btn.classList.toggle('active', btn.dataset.section === sectionId));
    localStorage.setItem('activeSection', sectionId);

    if (sectionId === 'appointments') await loadDashboard();
    else if (sectionId === 'consultations') await loadConsultations();
  }

  buttons.forEach(btn => btn.addEventListener("click", () => showSection(btn.dataset.section)));
  showSection(localStorage.getItem('activeSection') || 'dashboard');

  let defaultSlots = [];

  async function fetchFixedSlots() {
      try {
          const res = await fetch('/get_fixed_slots');

          if (!res.ok) throw new Error(`Failed to fetch slots: ${res.status}`);

          const contentType = res.headers.get("content-type") || "";
          if (!contentType.includes("application/json")) {
              throw new Error("Server returned HTML — likely not logged in or session expired");
          }

          const data = await res.json();
          defaultSlots = data.slots || [];
      } catch(err) {
          console.error('Error fetching slots:', err);
          defaultSlots = [];
      }
  }



  function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    // always return YYYY-MM-DD
    return d.toISOString().split('T')[0];
  }


  function populateSlots(slotSelect, dateInput) {
      if (!slotSelect || !dateInput) return;

      slotSelect.innerHTML = '<option value="">-- Select Slot --</option>';
      const date = dateInput.value;
      if (!date) return;

      const reserved = appts
          .filter(a => formatDate(a.date) === date && a.status !== "cancelled")
          .map(a => a.slot);

      defaultSlots.forEach(slot => {
          const option = document.createElement('option');
          option.value = slot;
          option.textContent = slot + (reserved.includes(slot) ? " (Booked)" : "");
          option.disabled = reserved.includes(slot);
          slotSelect.appendChild(option);
      });

      if (slotSelect.options.length === 1) {
          const opt = document.createElement('option');
          opt.textContent = 'No available slots';
          opt.disabled = true;
          slotSelect.appendChild(opt);
      }

      // Select first available slot automatically
      const firstAvailable = Array.from(slotSelect.options).find(o => !o.disabled && o.value);
      if (firstAvailable) slotSelect.value = firstAvailable.value;
  }

  // ---------- Appointments ----------
  let appts = [];

  async function loadDashboard() {
    try {
      const res = await fetch('/vet_dashboard_data');
      if (!res.ok) throw new Error(`Failed to fetch dashboard data: ${res.status}`);
      const data = await res.json();
      if (!data.success) throw new Error(data.error || "Unknown error");

      appts = Array.isArray(data.appointments) ? data.appointments : [];
      renderAppointments(appts);

      qs('#countToday').textContent = data.today_appointments ?? 0;
      qs('#countOpen').textContent = data.open_cases ?? 0;
      qs('#countCons').textContent = data.consultations_count ?? 0;
      qs('#countProfile').textContent = data.profile?.name || '—';
    } catch (err) {
      console.error("Error loading dashboard:", err);
      renderAppointments([]);
      ['#countToday','#countOpen','#countCons','#countProfile'].forEach(id => qs(id).textContent = id === '#countProfile' ? '—' : 0);
    }
  }

  function renderAppointments(list) {
    const tbody = document.querySelector('#apptTable tbody');
    if (!tbody) return;

    tbody.innerHTML = '';
    if (!Array.isArray(list) || list.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7">No appointments found</td></tr>';
      return;
    }

    list.slice().reverse().forEach(a => {
      const tr = document.createElement('tr');

      // Color code by status
      switch ((a.status || '').toLowerCase()) {
        case 'completed':
          tr.style.backgroundColor = '#e0f7e9'; // light green
          break;
        case 'cancelled':
          tr.style.backgroundColor = '#f8d7da'; 
          break;
        case 'pending':
        default:
          tr.style.backgroundColor = '#fff';
      }

      tr.innerHTML = `
        <td>${a.pet_name || '-'}</td>
        <td>${a.pet_type || '-'}</td>
        <td>${a.date ? new Date(a.date).toLocaleDateString('en-GB') : '-'}</td>
        <td>${a.slot || '-'}</td>
        <td>${a.status || 'scheduled'}</td>
        <td>${a.source === 'owner' ? 'Owner' : a.source === 'vet' ? 'Vet' : '-'}</td>
        <td>
          ${(a.status === "cancelled" || a.status === "done") ? '' : `
            <button class="btn ghost cancel-appt-btn" data-id="${a.id}" data-source="${a.source}">Cancel</button>
            <button class="btn ghost done-appt-btn" data-id="${a.id}" data-source="${a.source}">Done</button>
          `}
        </td>
      `;

      tbody.appendChild(tr);
    });
  }

  // ---------- Appointment Modal ----------
  const addApptBtn = qs('#addApptQuick');
  const addApptModal = qs('#addApptModal');
  const addApptForm = qs('#addApptForm');
  const modalDate = qs('#modal_date');
  const modalSlot = qs('#modal_slot');
  const cancelBtn = qs('#modalCancel');
  let isModalOpen = false;

  addApptBtn?.addEventListener('click', async () => {
      if (!addApptModal || isModalOpen) return;

      // Refresh dashboard and slots before opening modal
      await loadDashboard();       

      addApptForm.reset();
      modalSlot.innerHTML = '<option value="">-- Select Slot --</option>';
      modalSlot.disabled = true;
      modalDate.value = '';
      addApptModal.style.display = 'flex';
      isModalOpen = true;
      modalDate.focus();
  });



  cancelBtn?.addEventListener('click', closeModal);
  addApptModal?.addEventListener('click', e => { if(e.target === addApptModal) closeModal(); });

  function closeModal() {
    addApptModal.style.display = 'none';
    addApptForm.reset();
    modalSlot.innerHTML = '<option value="">-- Select Slot --</option>';
    modalSlot.disabled = true;
    modalDate.value = '';
    isModalOpen = false;
  }

  modalDate?.addEventListener('change', () => {
      if (!modalDate.value) {
          modalSlot.disabled = true;
          modalSlot.innerHTML = '<option value="">-- Select Slot --</option>';
          return;
      }
      modalSlot.disabled = false;
      modalSlot.value = '';
      if (defaultSlots.length && appts.length) populateSlots(modalSlot, modalDate);
  });



  addApptForm?.addEventListener('submit', async e => {
    e.preventDefault();
    const pet = qs('#modal_pet').value.trim();
    const type = qs('#modal_type').value.trim();
    const date = modalDate.value;
    const slot = modalSlot.value;
    const reason = qs('#modal_reason').value.trim();
    if (!pet || !type || !date || !slot || !reason) return alert("Please fill all fields");

    try {
      const res = await fetch('/add_appointment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pet_name: pet, pet_type: type, date, slot, reason })
      });
      const result = await res.json();
      if (!res.ok || !result.success) return alert(result.error || "Failed to save appointment");

      alert(`Appointment booked!\n${pet} • ${new Date(date).toLocaleDateString('en-GB', { day:'2-digit', month:'short', year:'numeric' })} • ${slot}`);
      
      closeModal();
      await loadDashboard(); // refresh dashboard and appts
    } catch (err) {
      console.error(err);
      alert("Error saving appointment");
    }
  });


  // ---------- Consultations ----------
  const addConsultForm = qs('#manualConsultForm');
  const ownerSelect = qs('#manualConsultOwner');
  const petSelect = qs('#manualConsultPet');
  const petTypeInput = qs('#manualConsultType');
  const notesInput = qs('#manualConsultNotes');
  const statusSelect = qs('#manualConsultStatus');
  const newPetFields = qs('#newPetFields');
  const newPetName = qs('#newPetName');
  const newPetType = qs('#newPetType');
  const existingPetTypeField = qs('#existingPetTypeField');

  let consultations = [];

  async function loadOwners() {
    try {
      const res = await fetch('/get_all_owners');
      if (!res.ok) throw new Error(`Failed to fetch owners: ${res.status}`);
      const owners = await res.json();

      ownerSelect.innerHTML = `<option value="">-- Select Owner --</option>`;
      owners.forEach(o => ownerSelect.appendChild(new Option(o.name, o.id)));

      petSelect.innerHTML = `<option value="">-- Select Pet --</option><option value="new">+ Add New Pet</option>`;
    } catch (err) {
      console.error('Error loading owners:', err);
    }
  }

  async function loadOwnerPets(ownerId) {
    petSelect.innerHTML = `<option value="">-- Select Pet --</option><option value="new">+ Add New Pet</option>`;
    if (!ownerId) return;

    try {
      const res = await fetch(`/get_owner_pets/${ownerId}`);
      if (!res.ok) throw new Error(`Failed to fetch pets: ${res.status}`);
      const pets = await res.json();

      pets.forEach(p => {
        const opt = document.createElement('option');
        opt.value = p.id;
        opt.textContent = `${p.name} (${p.type})`;
        opt.dataset.name = p.name;
        opt.dataset.type = p.type;
        petSelect.appendChild(opt);
      });
    } catch (err) {
      console.error('Error loading pets:', err);
    }
  }

  ownerSelect?.addEventListener('change', () => loadOwnerPets(ownerSelect.value));

  petSelect?.addEventListener('change', () => {
    const selected = petSelect.selectedOptions[0];
    if (!selected) return;
    if (selected.value === 'new') {
      newPetFields.style.display = 'block';
      existingPetTypeField.style.display = 'none';
      petTypeInput.value = '';
    } else {
      newPetFields.style.display = 'none';
      existingPetTypeField.style.display = 'block';
      petTypeInput.value = selected.dataset.type || '';
    }
  });

  addConsultForm?.addEventListener('submit', async e => {
    e.preventDefault();
    const owner_id = ownerSelect.value;
    if (!owner_id) return alert("Please select an owner");

    let pet_id = null, pet_name, pet_type;

    if (petSelect.value === 'new') {
      pet_name = newPetName.value.trim();
      pet_type = newPetType.value.trim();
      if (!pet_name || !pet_type) return alert("Please enter name and type for new pet");

      try {
        const resPet = await fetch('/add_pet', {
          method: 'POST',
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ owner_id, pet_name, pet_type })
        });
        const newPet = await resPet.json();
        if (!newPet.success) throw new Error(newPet.error || "Failed to add pet");

        pet_id = newPet.pet.id;
        pet_name = newPet.pet.name;
        pet_type = newPet.pet.type;
        await loadOwnerPets(owner_id);
        petSelect.value = pet_id;
        petTypeInput.value = pet_type;
      } catch (err) {
        console.error(err);
        return alert("Error adding new pet: " + err.message);
      }
    } else {
      const selected = petSelect.selectedOptions[0];
      pet_id = selected.value;
      pet_name = selected.dataset.name || null;
      pet_type = selected.dataset.type || null;
    }

    const notes = notesInput.value.trim();
    let status = statusSelect.value.trim().toLowerCase() || 'pending';
    const allowedStatuses = ['pending', 'completed', 'in-progress']; // add all allowed
    if (!allowedStatuses.includes(status)) status = 'pending';

    if (!notes) return alert("Please enter notes");

    try {
      const res = await fetch("/add_consultation", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ pet_id, pet_name, pet_type, notes, status, owner_id })
      });
      const result = await res.json();
      if (!res.ok || !result.success) throw new Error(result.error || "Failed to save");

      alert("Consultation added successfully!");
      addConsultForm.reset();
      newPetFields.style.display = 'none';
      existingPetTypeField.style.display = 'none';
      statusSelect.value = 'pending';
      resetPetSelect();
      await loadOwnerPets(owner_id);
      await loadConsultations();
    } catch (err) {
      console.error(err);
      alert("Error: " + err.message);
    }
  });

  function resetPetSelect() {
    petSelect.innerHTML = `<option value="">-- Select Pet --</option><option value="new">+ Add New Pet</option>`;
  }

  async function loadConsultations() {
    try {
      const res = await fetch("/vet_consultations_data");
      if (!res.ok) throw new Error(`Failed to fetch consultations: ${res.status}`);
      const data = await res.json();
      consultations = data.consultations || [];
      renderConsultations(consultations);
    } catch (err) {
      console.error('Error loading consultations:', err);
      renderConsultations([]);
    }
  }

  function renderConsultations(list) {
    const tbody = qs("#consTable tbody");
    if (!tbody) return;

    tbody.innerHTML = "";
    if (!list.length) {
      tbody.innerHTML = '<tr><td colspan="6">No consultations found</td></tr>';
      return;
    }

    list.forEach(c => {
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${c.pet_name || '-'}</td>
        <td>${c.pet_type || '-'}</td>
        <td>${c.owner_name || '-'}</td>
        <td>${c.notes || '-'}</td>
        <td>${c.status || '-'}</td>
        <td>${c.created_at ? new Date(c.created_at).toLocaleString() : '-'}</td>
      `;
      tbody.appendChild(tr);
    });
  }

// ---------- Appointment Table Buttons Handler ----------
document.querySelector('#apptTable tbody')?.addEventListener('click', async e => {
    const btn = e.target.closest('button');
    if (!btn || !btn.dataset.id) return;

    const row = btn.closest('tr'); // table row
    const { id } = btn.dataset;
    let newStatus = '';

    // Determine action
    if (btn.classList.contains('cancel-appt-btn')) {
        if (!confirm("Cancel this appointment?")) return;
        newStatus = 'cancelled';  // matches backend
    } else if (btn.classList.contains('done-appt-btn')) {
        newStatus = 'Completed';       // matches backend
    } else {
        return;
    }

    try {
        // Send status update to server
        const res = await fetch('/update_appointment_status', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ appointment_id: id, status: newStatus })
        });

        const result = await res.json();

        if (!res.ok || !result.success) throw new Error(result.error || "Failed to update");

        alert(`Appointment marked as ${newStatus}!`);

        // -------- Update table instantly --------
        const statusCell = row.children[4];  // Status column
        const actionCell = row.children[6];  // Actions column

        statusCell.textContent = newStatus;
        actionCell.innerHTML = '';           // remove Done/Cancel buttons

        // Optional: color code row
        if (newStatus === 'done') row.style.backgroundColor = '#e0f7e9';       // light green
        if (newStatus === 'cancelled') row.style.backgroundColor = '#f8d7da';  // light red

    } catch (err) {
        console.error("Error updating appointment:", err);
        alert("Error: " + err.message);
    }
});



  // ---------- Initial Load ----------
  resetPetSelect();
  await loadDashboard();   // populate 'appts' first
  await fetchFixedSlots(); // then fetch slots
  await Promise.all([loadOwners(), loadConsultations()]);

});
